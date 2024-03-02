+++
title = "Pivoting 100GB text files from long to wide"
date = "2022-11-28"
shorturl = "big-pivot"
recommended = "false"
+++

Recently, I've been working on a project involving travel time matrices. These matrices are the output of specialized [routing software](https://github.com/conveyal/r5) and are used in social science research, urban planning, and policy analysis. They look like this:

| origin | destination | minutes |
|--------|-------------|---------|
|    A   |      A      |    0    |
|    A   |      B      |    9    |
|    A   |      C      |    15   |
|    B   |      A      |    10   |
|    B   |      B      |    0    |
|    B   |      C      |    21   |
|    C   |      A      |    13   |
|    C   |      C      |    0    |

Where **origin** and **destination** are the identifiers of geographic points (usually Census geography centroids) and **minutes** is the travel time between the points.

This is the "long" travel time matrix format. It's the typical output of routing software, but instead of 6 rows, each matrix has millions or even billions of rows. The software outputs each matrix as a plain CSV file, which is then compressed to a more manageable size.

The long matrix format is simple and easy to work with, but has some major drawbacks. Mainly, it:

- Repeats identifiers (A is repeated 3 times in the matrix above), which costs space.
- Makes lookups difficult, since finding a specific origin-destination pair requires either scanning the entire file or using an index (which costs more space).
- Doesn't include pairs missing from the Cartesian product of origins and destinations. Such missing pairs are often useful for debugging routing issues.

We can fix all these issues by converting our long format to "wide" format, with origins as rows and destinations as columns. The wide version of the matrix above looks like this:

| origin |  A | B |  C |
|--------|----|---|----|
|    A   |  0 | 9 | 15 |
|    B   | 10 | 0 | 21 |
|    C   | 13 | - | 0  |

This format saves space, compresses better, and shows missing origin-destination pairs. It can also be converted into a modern columnar storage format like Parquet for easy column lookups, built-in compression, and handy metadata.

---

## Problem

Pivoting these matrices is *hard*.

In most cases, data can be easily pivoted from long to wide using functions from [popular data manipulation libraries](https://github.com/Rdatatable/data.table). However, such libraries typically work with data in-memory, and travel time matrices can be over 100GB uncompressed, making them impossible to fit in-memory on most machines.

As such, we need to find a method to pivot the travel time data *without storing it in-memory*. Our method should also:

1. Handle missing pairs i.e. each origin doesn't go to all destinations.
2. Handle origin and destination lists of any size. Some matrices have 100K+ destinations for each origin.
3. Read from a compressed file, do its work, then write to a compressed file. This is critical, as it prevents mangling disks by writing hundreds of gigabytes of uncompressed text data for each matrix.
4. Be extremely fast, since each matrix is huge and my project involves a *lot* of matrices.

Fortunately, we have some conditions and additional information that make this task easier. Each matrix:

1. Is numerically ordered by origin, then destination (as seen in the example long table).
2. Includes a separate file containing the unique set of destinations.

I couldn't find any off-the-shelf or obvious solutions to this problem. I imagine it's too niche to warrant much attention. We'll have to roll our own.

---

## Solutions

Given our requirements, the simplest (IMO) solution is text stream processing using bash pipes. This approach saves almost no data in-memory, is fast (enough), and uses pre-existing CLI tools to handle compression. All we need to do is write code to perform the long-to-wide pivot on the text stream.

### Awk

`awk` is first tool I reach for when doing any sort of text stream processing. It's stupidly powerful, if a bit esoteric and finicky.

Here we can use it to iterate through rows and match each value's position to an array of possible destinations (columns). This approach stores only the destinations and a temporary array of values in-memory.

```awk
# Create an array of columns (destinations) from a
# separate input file
BEGIN {
    FS=OFS=","
    while ((getline line <dests) > 0) {
        contents = contents line
    }
    numCols = split(contents,cols)
}

# Create the CSV header by printing each destination
FNR == 1 {
    printf "%s", $1
    for (c=1; c<=numCols; c++) {
        dest = cols[c]
        printf "%s%s", OFS, dest
    }
    print ""
    next
}

# Loop through rows, appending each value to an array
# based on its corresponding destination. Once the
# origin changes, print the array, then start a new row
# in the output stream
$1 != prev[1] {
    if ( FNR > 2 ) {
        prt()
    }
    split($0,prev)
}
{ values[$2] = $3 }
END { prt() }

function prt(destination, value, c) {
    printf "%s", prev[1]
    for (c=1; c<=numCols; c++) {
        destination = cols[c]
        value = values[destination]
        printf "%s%d", OFS, value
    }
    print ""
    delete values
}
```

The script (saved as `pivot.awk`) is called using the following bash command:

```bash
# Read the file and add progress bar with pv, then decompress
# the input stream (bz2), pivot with awk, and recompress with zstd
# The list of unique destinations is passed to awk as a variable
pv in.csv.bz2 \
  | pbzip2 -dc \
  | awk -v dests=<(cat dests.csv | paste -s -d, -) -f pivot.awk \
  | zstd \
  > out.csv.zst
```

This approach works, but is extremely slow for large matrices (see [results](#results)). Let's find something better.

### Rust approach A (naive)

Given the need for performance, a lower-level language is the obvious next step. Let's try using Rust.

<p class="notice">
I don't have much experience with compiled languages (most of my work uses Python/R), but I took this as an opportunity to learn something new. I chose Rust because it has great documentation, easy-to-use tooling, and a (seemingly) large community. Also, I was intimidated by the complexity of older languages like C/C++.<br><br>I have to say, I'm incredibly impressed by Rust. I managed to get a working prototype binary in about 2 hours despite <em>almost no experience with compiled languages</em>, mostly thanks to the excellent book, linting, and compiler hints. That said, please forgive any code smell; I'm learning (in public) as I go.
</p>

My naive approach does nearly the same thing as the `awk` script. First, it stores the destinations as keys in a dictionary (`BTreeMap` in Rust). Then, it takes lines from stdin, populates the dictionary values, and then prints the values to stdout for each origin. The code is a bit more extensive, so I'll link to GitHub rather than showing it here.

**[GitHub gist for naive rust code](https://gist.github.com/dfsnow/112621a2d9ea6e19876017fb776cf133#file-pivot-rs)**

The resulting binary (named `pivot`) is called similarly to the `awk` script:

```bash
pv in.csv.bz2 \
  | pbzip2 -dc \
  | ./pivot dests.csv \
  | zstd \
  > out.csv.zst
```

This approach is nearly 10x faster than the `awk` script. However, there are a couple things to improve:

- Cloning a fresh, unpopulated dictionary (only keys, no values) for each origin seems incredibly wasteful, but I'm not sure how else to clear the dictionary values.
- All origins and destinations are strings. Making them unsigned integers or similar might be faster.
- Lots of `.to_string()` calls which may be unnecessary.

### Rust approach B (improved)

Given my relative lack of experience with compiled languages, I figured it might be worthwhile to seek input from various Rust-specific forums. I was a little intimidated at first, but the Rust community turned out to be unreasonably helpful.

I got dozens of responses, ranging from correcting small syntax issues to literally rewriting my entire project. My favorite response (credit to theiz) had a relatively straightforward approach:

1. Create a vector of all destinations from the separate argument file.
2. Allocate a vector of commas with the same length as (1).
3. Pre-allocate a big string that can hold all the minute values for a given origin.
4. For each line from stdin, push a value into the string from (3) when the destination matches the expected value from (1), else skip and fill with commas from (2).

**[GitHub gist for improved rust code](https://gist.github.com/dfsnow/112621a2d9ea6e19876017fb776cf133#file-pivot_fast-rs)**

This approach uses minimal allocations, is 8x faster than the naive approach, and is almost 60x faster than the `awk` script. I can't think of many ways to improve it besides multithreading or similar complexity.

It does have one downside: the input file *must* be sorted by origin and destination. If the destinations are not sorted, then the loop will break. The naive approach doesn't have this restriction.

---

## Results

We can measure the speed of each approach using two test files. Each one is sorted (by origin, then destination) and has its unique destinations extracted to a separate file.

- **File A** - [17031-output-TRACT-CAR.csv.bz2](https://uchicago.box.com/shared/static/kqzt7x8wwnv2qp7fniycwi8m1yrvym93.bz2)
  - 13MB compressed, 108M uncompressed
  - 3.8 million rows (origin-destination pairs)
  - 1318 unique origins, 2869 unique destinations
- **File B** - [06037-output-BLOCK-WALK.csv.bz2](https://uchicago.box.com/shared/static/kmnqdyd4kl99bozykrf8ej0bm7im2mvp.bz2)
  - 1.1GB compressed, 11GB uncompressed
  - ~300 million rows (origin-destination pairs)
  - 105,957 unique origins, 115,936 unique destinations

The results shown below are from a 2022 MacBook Air M2 with a 1TB SSD. Speed is measured with `pv` and total time with `time`. Parallel bzip2 (`pbzip2`) is used for decompression, and Z-standard (`zstd`) is used for recompression. You can find more long matrix files on the PySAL spatial access [resources page](https://pysal.org/access/resources.html).

<table style="width:100%;">

  <thead>
    <tr>
      <th style="border:0;"></th>
      <th colspan="1">File A</th>
      <th colspan="2">File B</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <th>Method</th>
      <th>Time (Real)</th>
      <th>Time (Real)</th>
      <th>Avg. Speed</th>
    </tr>
    <tr>
      <td>awk</td>
      <td>6.45s</td>
      <td>3h22m8.07s</td>
      <td>124KiB/s</td>
    </tr>
    <tr>
      <td>Rust A (naive)</td>
      <td>1.86s</td>
      <td>15m23.42s</td>
      <td>1.11MiB/s</td>
    </tr>
    <tr>
      <td>Rust B (improved)</td>
      <td>1.24s</td>
      <td>2m22.02s</td>
      <td>7.13MiB/s</td>
    </tr>
    <tr>
      <td>Baseline (no pivoting)</td>
      <td>1.15s</td>
      <td>0m25.51s</td>
      <td>40.6MiB/s</td>
    </tr>
  </tbody>
</table>

Some thoughts:

- `awk` is blown out of the water by the two Rust solutions, so it's firmly out of the running for this particular task.
- Rust solution A is nearly as fast as B for smaller files. Considering that it's slightly more robust (doesn't expect sorted destinations), I may use it for matrices smaller than 1GB.
- Rust solution B is the only real option for super large matrices. As far as I can tell it has `O(n)` time complexity. I tested it on a 121GB Census block matrix and found only a slight decrease in average speed. Super impressive.

Notably, the compressed wide matrix files are typically 30-50% smaller than their long equivalents, depending on sparsity.

## Conclusion

So that's it. Our matrices are pivoted and resaved as `.zst` files. They can be loaded into any software that accepts wide matrices or converted to Parquet/ORC (more on that later).

This was a fun, challenging little project and turned into a great opportunity to learn a new language. I'm really happy I chose Rust. It's such a delight to work in, even if I don't yet fully grok it. Feel free to email or comment on the [gist](https://gist.github.com/dfsnow/112621a2d9ea6e19876017fb776cf133) if I've missed any obvious improvements.
