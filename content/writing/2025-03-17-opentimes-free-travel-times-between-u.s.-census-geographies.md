+++
title = "OpenTimes: Free travel times between U.S. Census geographies"
date = "2025-03-17"
url = "/opentimes"
aliases = [ "/writing/2025/03/17/opentimes-free-travel-times-between-u.s.-census-geographies/" ]
recommended = "true"
+++

Today I'm launching [OpenTimes](https://opentimes.org), a free database of
pre-computed, point-to-point travel times between major U.S. Census geographies.
In addition to letting you [visualize travel isochrones](https://opentimes.org),
OpenTimes also lets you download massive amounts of travel time data for free
and with no limits. Visit the dedicated [about page](https://opentimes.org/about)
to learn more about the project.

The primary goal here is to enable research and fill a gap I noticed in the
open-source spatial ecosystem. Researchers (social scientists, economists) use
large travel time matrices to quantify things like access to healthcare, but
they often end up paying Google or Esri for the necessary data. By pre-calculating
times between commonly-used research geographies (i.e. Census) and then making
those times easily accessible via SQL, I hope to make large-scale accessibility
research cheaper and simpler.

OpenTimes covers all 50 states (and D.C.), 3 travel modes (driving, biking, and
walking), and 6 Census geographies. Here's what the actual data looks like
as a table:

| origin_id | destination_id | duration_sec |
|:---------:|:--------------:|-------------:|
| 060750328021     | 060750328021          | 0            |
| 060750328021     | 060750328023          | 284.1         |
| 060750328021     | 060750328022          | 322.5         |
| 060750328021     | 060750326023          | 479.7         |
| ...       | ...            | ...          |

And here's that same data on the homepage map:

{{< picture-embed src="/2025-03-16-opentimes.png" alt="Isochrone map of travel times">}}

OpenTimes also has some interesting technical stuff going on, most of which
I haven't seen replicated elsewhere:

- The entire OpenTimes backend is just static Parquet files on
  [Cloudflare's R2](https://www.cloudflare.com/developer-platform/products/r2/).
  There's no RDBMS or running service, just files and a CDN. The whole thing
  costs about $10/month to host and costs nothing to serve. In my opinion,
  this is a _great_ way to serve infrequently updated, large public datasets
  at low cost (as long as you partition the files correctly).
- All travel times were calculated by pre-building the inputs (OSM, OSRM networks)
  and then distributing the compute over
  [hundreds of GitHub Actions jobs](https://github.com/dfsnow/opentimes/actions/workflows/calculate-times.yaml).
  This worked shockingly well for this specific workload (and was also completely free).
- The query layer uses a single DuckDB database file with _views_ that point
  to static Parquet files via HTTP. This lets you query a table with hundreds of
  billions of records after downloading just the ~5MB pointer file.
- The map frontend uses a Javascript Parquet library called
  [hyparquet](https://github.com/hyparam/hyparquet) to query the same static
  Parquet files as DuckDB. Once the Parquet files are cached the map is
  actually super responsive.

I built most of OpenTimes during a 6-week stint at the
[Recurse Center](https://www.recurse.com/scout/click?t=e5f3c6558aa58965ec2efe48b1b486af),
where it was my main project. Many thanks to the wonderful folks there!
