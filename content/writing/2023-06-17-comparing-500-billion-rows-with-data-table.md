+++
title = "Comparing 500 billion rows with data.table"
date = "2023-06-17"
url = "/big-data-table"
aliases = [ "writing/2023/06/17/comparing-500-billion-rows-with-data.table/" ]
recommended = "false"
+++

Recently, I've been working on a project that requires the element-wise comparison of many rows. The goal is to calculate a sort of similarity score between two tables. A simplified version of the data/problem looks like this:

<span style="margin:-1rem;display:block;text-align:center;"><strong>Table X</strong></span>

| ID  | V1  | V2  | V3  | V4  | V5  |
|:---:|:---:|:---:|:---:|:---:|:---:|
| X1  |  9  |  3  |  2  |  4  |  5  |
| X2  |  9  |  1  |  2  |  1  |  1  |

<span style="margin-bottom:-1rem;display:block;text-align:center;"><strong>Table Y</strong></span>

| ID  | V1  | V2  | V3  | V4  | V5  |
|:---:|:---:|:---:|:---:|:---:|:---:|
| Y1  |  9  |  3  |  3  |  1  |  1  |
| Y2  |  1  |  1  |  1  |  1  |  1  |
| Y3  |  9  |  9  |  7  |  9  |  8  |

Each row of Table X is compared to each row of Table Y and the elements are replaced with a boolean. This happens element-wise, so `X1, V1` is compared to `Y1, V1`, `X1, V2` is compared to `Y1, V2`, etc. The comparison of row X1 to all rows in Table Y looks like this:

| ID_X | ID_Y |  V1   |  V2   |  V3   |  V4   |  V5   |
|:----:|:----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|  X1  |  Y1  | TRUE  | TRUE  | FALSE | FALSE | FALSE |
|  X1  |  Y2  | FALSE | FALSE | FALSE | FALSE | FALSE |
|  X1  |  Y3  | TRUE  | FALSE | FALSE | FALSE | FALSE |

Each row of this boolean table is multiplied by a vector of pre-determined weights (the same length as the number of columns) and then summed to determine the final similarity between row X1 and the rows of Table Y. If the weights are `5, 4, 3, 2, 1`, then the resulting table becomes:

| ID_X | ID_Y | V1  | V2  | V3  | V4  | V5  |
|:----:|:----:|:---:|:---:|:---:|:---:|:---:|
|  X1  |  Y1  |  5  |  4  |  0  |  0  |  0  |
|  X1  |  Y2  |  0  |  0  |  0  |  0  |  0  |
|  X1  |  Y3  |  5  |  0  |  0  |  0  |  0  |

Summed by row, the total similarity score between row X1 and all of Table Y is:

| ID_X | ID_Y | score |
|:----:|:----:|:-----:|
|  X1  |  Y1  |   9   |
|  X1  |  Y2  |   0   |
|  X1  |  Y3  |   5   |

And for all rows of Table X and all rows of Table Y:

| ID_X | ID_Y | score |
|:----:|:----:|:-----:|
|  X1  |  Y1  |   9   |
|  X1  |  Y2  |   0   |
|  X1  |  Y3  |   5   |
|  X2  |  Y1  |   8   |
|  X2  |  Y2  |   7   |
|  X2  |  Y3  |   5   |

Great, seems simple enough, right? We can loop through the rows of Table X and sum the resulting rows for each comparison to Table Y. What's the problem?

---

## Problem

The real table X and Y are *big*, and the product of their comparison is absolute *huge*.

- Table X is 1.1M rows by 1,500 columns.
- Table Y is 450K rows by 1,500 columns.

Comparing just one row of Table X to Table Y requires 450K comparisons, and each comparison is between a 1,500 element vector. Comparing all of Table X to Table Y requires `1.1M * 450K` comparisons and thus results in around 500 billion similarity scores.

At that scale, many of the obvious solutions to this problem just sort of... break. They quickly run out of memory or have runtimes measured in weeks. In order to make this data useful, we must find a solution that not only *runs* but that also runs *extremely fast*.

### Caveats

To make the problem slightly more tractable for this post, we will:

1. Only use R, though there are probably much faster solutions in compiled languages.
2. Generate much smaller test data than the real data so we can benchmark solutions without waiting for days. Here's the data generation in R:

```r
library(data.table)
library(microbenchmark)

n_col <- 500
n_rows_x <- 100
n_rows_y <- 10000
weights <- runif(n_col)

# Table X becomes 100 x 500
x_df <- data.table(
  ID = paste0("X", seq_len(n_rows_x)),
  matrix(
    sample.int(n_col, n_col * n_rows_x, replace = TRUE),
    ncol = n_col,
    nrow = n_rows_x
  )
)

# Table Y becomes 10000 x 500
y_df <- data.table(
  ID = paste0("Y", seq_len(n_rows_y)),
  matrix(
    sample.int(n_col, n_col * n_rows_y, replace = TRUE),
    ncol = n_col,
    nrow = n_rows_y
  )
)
```

---

## Solutions

The goal is to perform a weighted comparison of each row of Table X to each row of Table Y, and to do so *quickly* and with the maximum possible memory efficiency. Here are some of the solutions I tried as well as the one I eventually landed on.

### For loop

The first thing I (or more accurately, my intern) tried was a simple for loop. This is very memory-efficient since it's basically just looping through columns of existing data and sticking the results into a pre-allocated output matrix. However, it takes around 8 seconds to finish on the test data, meaning it would likely take *weeks* to finish on the real data. No good.

```r
calc_sim_for <- function(x, y, weights) {
  x_nrow <- nrow(x)
  score <- matrix(0, nrow = x_nrow, ncol = nrow(y))

  for (row in seq_len(x_nrow)) {
    i <- 1
    for (col in colnames(y)) {
      matches <- y[[col]] == x[row, ][[col]]
      score[row, ] <- score[row, ] + weights[i] * matches
      i <- i + 1
    }
  }

  return(t(score))
}

microbenchmark(
  "for" = calc_sim_for(x_df[, -1], y_df[, -1], weights),
  unit = "millisecond",
  times = 5
)
```

```output
Unit: milliseconds
  expr  min   lq mean median   uq  max neval
   for 7478 7493 7553   7515 7612 7664     5
```

### Apply and matrix ops

Next, I tried using `apply()` to compare each table column-wise and then using matrix multiplication for the weights. This turned out to be even slower than the for loop.

```r
calc_sim_apply <- function(x, y, weights) {
  x_nrow <- nrow(x)
  score <- matrix(0, nrow = x_nrow, ncol = nrow(y))
  t_y <- as.matrix(t(y))
  m_x <- as.matrix(x)

  for (row in seq_len(x_nrow)) {
    match_matrix <- apply(t_y, MARGIN = 2, "==", m_x[row, ])
    score[row, ] <- weights %*% as.matrix(match_matrix)
  }

  return(t(score))
}

microbenchmark(
  "apply" = calc_sim_apply(x_df[, -1], y_df[, -1], weights),
  unit = "millisecond",
  times = 5
)
```

```output
Unit: milliseconds
  expr   min    lq  mean median    uq   max neval
 apply 16197 16213 16407  16422 16543 16659     5
```

### Vector recycling

Next, I tried to take advantage of R's fast matrix operations by comparing each row of Table X to a transposed version of Table Y. This works because vector-to-matrix comparisons are column-wise, and the single row of X (converted to a vector) is recycled automatically. This is much faster than `apply()` or the for loop, but still isn't nearly fast enough.

```r
calc_sim_mat <- function(x, y, weights) {
  x_nrow <- nrow(x)
  score <- matrix(0, nrow = x_nrow, ncol = nrow(y))
  t_y <- t(y)

  for (row in seq_len(x_nrow)) {
    vec_x <- as.numeric(x[row, ])
    score[row, ] <- unname(colSums((t_y == vec_x) * weights))
  }

  return(t(score))
}

microbenchmark(
  "mat" = calc_sim_mat(x_df[, -1], y_df[, -1], weights),
  unit = "millisecond",
  times = 5
)
```

```output
Unit: milliseconds
  expr  min   lq mean median   uq  max neval
   mat 2118 2131 2142   2133 2153 2176     5
```

### Pure data.table

I *really* like R's `data.table` package. These days I find myself reaching for it whenever speed and memory efficiency are a concern. However, I wasn't sure it was suitable for this problem. After messing around with `lapply()` and some other options, I found an approach that is incredibly simple *and* fast. Here's how it works:

1. Pivot the input matrices from wide to long using `data.table::melt()`. The original Table X becomes the table shown below.
2. Use `data.table`'s keys to index the resulting long tables.
3. Join the long Table X and long Table Y on `V` and `IDX`.
4. Replace the value of `V` with the corresponding weight, then sum for each group of X and Y IDs.

```output
    ID  V IDX
 1: X1 V1   9
 2: X2 V1   9
 3: X1 V2   3
 4: X2 V2   1
 5: X1 V3   2
 6: X2 V3   2
 7: X1 V4   4
 8: X2 V4   1
 9: X1 V5   5
10: X2 V5   1
```

This approach gains most of its speed by taking advantage of `data.table`'s indexed joins and aggregations. But just how fast is it?

``` r
calc_sim_dt <- function(x, y, id_col, weights) {
  x_nrow <- nrow(x)
  y_nrow <- nrow(y)
  id_col_i <- paste0("i.", id_col)
  names(weights) <- colnames(x)[-1]

  # Pivot X and Y from wide to long, add keys to the results
  x_m <- data.table::melt(
    data = x,
    id.vars = id_col,
    variable.name = "V",
    value.name = "IDX"
  )
  data.table::setkeyv(x_m, cols = c("V", "IDX"), physical = TRUE)
  y_m <- data.table::melt(
    data = y,
    id.vars = id_col,
    variable.name = "V",
    value.name = "IDX"
  )
  data.table::setkeyv(y_m, cols = c("V", "IDX"), physical = TRUE)

  # Join on the pivoted columns, then aggregate to get scores
  out <- y_m[
    x_m,
    on = .(V, IDX),
    nomatch = NULL,
    allow.cartesian = TRUE
  ][
    , c("V", "IDX") := .(weights[V], NULL)
  ][
    , .(score = sum(V)),
    keyby = c(id_col_i, id_col)
  ]

  # Clean up the results
  data.table::setnames(
    x = out,
    old = c(id_col_i, id_col),
    new = c(paste0(id_col, "_X"), paste0(id_col, "_Y"))
  )

  return(out)
}

# Use all threads for data.table
setDTthreads(0)

# Comparing all solutions
microbenchmark(
  "for" = calc_sim_for(x_df[, -1], y_df[, -1], weights),
  "apply" = calc_sim_apply(x_df[, -1], y_df[, -1], weights),
  "mat" = calc_sim_mat(x_df[, -1], y_df[, -1], weights),
  "dt" = calc_sim_dt(x_df, y_df, "ID", weights),
  unit = "millisecond",
  times = 5
)
```

```output
Unit: milliseconds
  expr   min    lq  mean median    uq   max neval
   for  7547  7651  7802   7856  7887  8067     5
 apply 17223 20289 20026  20447 20697 21476     5
   mat  2169  2204  2214   2214  2217  2266     5
    dt   141   144   168    150   201   206     5
```

Oh. It's a full order of magnitude faster than everything else. Looks like `data.table` is our winning solution!

---

## Conclusion

So, that's the test data, but what about the original problem with 500 billion rows? Can the `data.table` solution actually finish running it?

Yes it can! Though with some caveats:

- `data.table` has a limit of `2 ^ 31` rows resulting from a join. To stay below that limit, the input Table X needs to be processed in chunks, which slows things down a bit.
- Saving *every* score between rows isn't actually necessary. What we're really after is the top N most similar rows of Table Y given a row in X. This significantly shrinks the required memory and ultimately the size of the output.

I wrote some additional code to handle these caveats and ran it on the full data. Given 1.1M rows in X and 450K rows in Y, each with 1,500 columns, the code took `31H 27M 18S` to run on a beefy server (128G RAM, 16 cores of a Xeon Silver 4208 using `data.table`'s built-in parallelism). Still slow, but totally manageable given the nature of the task.

That said, I'm sure this could be done faster using a lower-level language. I did some quick experiments using Rcpp, but I don't think I'm skilled enough to beat the times I got with `data.table`. If anyone does manage to find a faster solution, feel free to email me; I'll gladly buy you a beer.

---

## Update (2023-06-21)

I owe someone a beer. [My friend](https://nicktallant.com) pointed out that a simple nested for loop in Python using `numpy` is nearly as fast as the `data.table` solution.

<details>
<summary>
Click to view setup code
</summary>

```r
library(reticulate)
x <- as.matrix(x_df[, -1])
y <- as.matrix(y_df[, -1])
```

```python
import time
import numpy as np

# Import objects from R to numpy using reticulate
x = r.x
y = r.y
w = np.array(r.weights)

# Define janky microbenchmark analogue
def benchmark(func, x, y, w, expr, times):
    exp_j = max(len(expr), 4) + 1
    timings = np.empty(times, np.float32)
    for i in range(times):
        start = time.perf_counter()
        func(x, y, w).shape
        end = time.perf_counter()
        timings[i] = round((end - start) * 100, 3)

    print("Unit: milliseconds")
    print("expr".rjust(exp_j, " ") +
      " min  lq mean median  uq max neval\n",
      expr.rjust(exp_j - 1, " ") +
      str(np.int16(np.min(timings))).rjust(4, " ") +
      str(np.int16(np.quantile(timings, 0.25))).rjust(4, " ") +
      str(np.int16(np.mean(timings))).rjust(5, " ") +
      str(np.int16(np.median(timings))).rjust(7, " ") +
      str(np.int16(np.quantile(timings, 0.75))).rjust(4, " ") +
      str(np.int16(np.max(timings))).rjust(4, " ") +
      str(times).rjust(6, " ")
    )
```

</details>

```python
def calc_sim_py(x, y, w):
    output = np.zeros((len(x), len(y)), np.float64)
    for idx_x, x_row in enumerate(x):
        for idx_y, y_row in enumerate(y):
            output[idx_x][idx_y] = np.sum((x_row == y_row) * w)
    return output

benchmark(calc_sim_py, x, y, w, "py", times = 5)
```

```output
Unit: milliseconds
  expr min  lq mean median  uq max neval
    py 299 301  302    302 302 305     5
```

And that compiling the same loop with [`numba`](https://numba.pydata.org)'s `@njit` decorator reduces the time even further, down to around a half the time of `data.table`. Pretty wild!

``` python
from numba import njit, prange

@njit
def calc_sim_py_njit(x, y, w):
    output = np.zeros((len(x), len(y)), dtype=np.float64)
    for x_idx, x_row in enumerate(x):
        for y_idx, y_row in enumerate(y):
            output[x_idx][y_idx] = np.sum((x_row == y_row) * w)
    return output

benchmark(calc_sim_py_njit, x, y, w, "py_njit", times = 5)
```

```output
Unit: milliseconds
    expr min  lq mean median  uq max neval
 py_njit  80  80   87     80  80 114     5
```

---

## Update (2023-06-23)

I owe two beers. My coworker has further sped up the `numpy` loops using `numba`'s built-in parallelization. So now we've dropped three orders of magnitude from the original R for loop. Can we go even faster?

```python
from numba import njit, prange

@njit(parallel=True, fastmath=True)
def calc_sim_py_par(x, y, w):
    output = np.zeros((len(x), len(y)), dtype=np.float64)
    for x_i in prange(len(x)):
        for y_i in range(len(y)):
            output[x_i][y_i] = np.sum((x[x_i] == y[y_i]) * w)
    return output

benchmark(calc_sim_py_par, x, y, w, "py_par", times = 50)
```

```output
Unit: milliseconds
    expr min  lq mean median  uq max neval
  py_par   6   7    8      7   8  43    50
```
