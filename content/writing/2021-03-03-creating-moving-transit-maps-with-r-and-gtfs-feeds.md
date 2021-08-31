+++
title = "Creating moving transit maps with R and GTFS feeds"
date = "2021-03-03"
shorturl = "transit-maps"
recommended = "true"
+++

<h4>
<a href="https://gist.github.com/dfsnow/6cef8184ed0dbccadc0cd56a0d22b8be">GitHub gist for source code</a>
</h4>

I've been on a bit of a transit kick this month. I read [Human Transit](https://humantransit.org/) (the blog and the book) and have been playing a lot of [Mini Metro](https://dinopoloclub.com/games/mini-metro/).

I've also been playing around with [GTFS feeds](https://gtfs.org/), which are a standardized data format for public transit systems. They provide schedules, stop locations, route shapes, and more. 

I wanted to see if I could take a GTFS feed and turn it into an animated map in the style of Mini Metro (I love its aesthetic). Turns out it's actually pretty easy.

{{< video_loop src="/2021-03-03-chicago-gtfs" >}}
{{< video_loop src="/2021-03-03-dc-gtfs" >}}

These maps are made using [R](https://cloud.r-project.org/) and [ggplot2](https://ggplot2.tidyverse.org/). Each frame of animation is a separate plot combined using [ffmpeg](https://ffmpeg.org/). There are probably better/faster ways to animate besides rendering each frame, but this way is easy and flexible. 

## Walkthrough

You can find the code to make these maps at the GitHub gist at the top of the page. It only works for single feeds (so no New York, which has many separate feeds) and only for trains, though it could be easily adapted to other route types.

It's relatively simple code, so rather than explain it step-by-step, I'll walkthrough the general process of creating a map. Anything in `snake_case` refers to an object in the code.

### Create the data

First, we need to download a GTFS feed and convert it into a format useable in R. The map needs three data sets to work:

1. A spatial data frame of stop locations (`stop_shapes`)
2. A spatial data frame of track shapes (`route_shapes`)
3. A data frame of the point location of all trains at any time within the specified window (`final_df`)

{{< picture_embed src="/2021-03-03-gtfs-data-types.svg" alt="Primary data sets for animation" width="1277" height="634">}}

The first two data sets are contained in the feed, but the third data set is not. In order to create it, we need locations and arrival times for not only stops, but also the *points between stops*. GTFS feeds don't contain that information, but they do contain data we can use to figure it out, mainly:

1. The geographic location of each stop (`stops_df`)
2. Each train's scheduled arrival time for a given stop (`stops_df`)
3. The shape of the track between stops, which we can convert to waypoints for the train to follow. These waypoint don't have arrival times (`waypoints_df`)

{{< picture_embed src="/2021-03-03-gtfs-interp-data.svg" alt="Combining stops and waypoints" width="1800" height="1057">}}

Combining these two data sets gives us the position and arrival time of stops *and* the position (but not time) of waypoints between stops. We can then use [Stineman interpolation](https://pages.uoregon.edu/dgavin/software/stineman.pdf) to fill in the missing times.

{{< picture_embed src="/2021-03-03-gtfs-final-data.svg" alt="Interpolating missing times" width="1584" height="949">}}

The final data set (`final_df`) is what creates the actual animation. It contains a list of geographic points and corresponding arrival times for each train.

### Generate the animation frames

Finally, we create a `ggplot2` object and add animation with `gganimate`. There are two important components here:

1. `transition_components(time)`, which tells `gganimate` to cycle through the window of time defined in `final_df`
2. `geom_point()` with a `group = trip_id` aesthetic, which tells `gganimate` to treat each train as a single point that moves along through time

The resulting object is passed to the `animate()` function, which then generates the inidividual frames. `gganimate` will use the `tweenr` package to further interpolate point locations for smoother animations. 

### Convert to video

The output of `animate()` is a folder of individual `.png` plots. These can be combined into a single video using ffmpeg. I used the following settings:

```bash
ffmpeg -framerate 60 \
  -pattern_type glob -i './gganim_plot*.png' \
  -c:v libx264 -profile:v main -preset fast \
  -strict experimental -movflags +faststart -pix_fmt yuv420p \
  output.mp4
```

And then one more pass to create a WebM file as a fallback for HTML `<video>` tags:

```bash
ffmpeg -i output.mp4 -b:v 0 -crf 45 -an -f webm output.webm
```

Overall, this method works fairly well. It takes awhile to generate the individual frames, but the resulting animation is crisp, smooth, and beautiful. Pretty good for less than 200 lines of code.
