+++
title = "Exporting Jellyfin playback stats to Prometheus"
date = "2023-11-25"
url = "/jellyfin-stats"
aliases = [ "/writing/2023/11/25/exporting-jellyfin-playback-stats-to-prometheus/" ]
recommended = "false"
styles = [ "css/full-width-media.scss" ]
+++

<style media="screen">
  :root { --add-media-width: 80px }
  .content > .video-holder {
    margin: 2rem auto;
  }
</style>

<h4>
<a href="https://gist.github.com/dfsnow/aad4ec99afb413968c49efb03bdb1ab9">GitHub gist for source code</a>
</h4>

_Edit: It turns out there's a much simpler way to do this. See the [update](#update-2024-02-23) below._

I run a small [Jellyfin](https://github.com/jellyfin/jellyfin) server at home to watch movies and other media I've collected over the years. Recently, in order to debug some playback/networking issues, I wanted a way to answer the following questions via [Prometheus](https://prometheus.io) and [Grafana](https://grafana.com):

1. What media is Jellyfin currently playing?
2. Who is playing that media?
3. How much bandwidth is the playback using?

Basically, I wanted to make this graph in Grafana:

{{< video-loop src="/2023-11-24-jellyfin-grafana" >}}

This turned out to be way harder than I thought, but I eventually got it working using the Jellyfin REST API and Prometheus JSON exporter. This post walks through what I did.

---

## The Jellyfin REST API

Jellyfin has a [built-in Prometheus endpoint](https://jellyfin.org/docs/general/networking/monitoring/) at `$BASE_URL/metrics`, but it's extremely bare-bones and didn't return the playback stats I wanted. There are also full-featured statistics applications like [Jellystat](https://github.com/CyferShepard/Jellystat), but they seemed like overkill for my needs.

Eventually, I stumbled across the [Jellyfin REST API](https://api.jellyfin.org). It's an extensive API that lets you basically do whatever you want in Jellyfin. However, it's very poorly documented and I couldn't find many examples of actually using it to do stuff.

[This blog post](https://jmshrv.com/posts/jellyfin-api/) by James Harvey (creator of Finamp) turned out to be a lifesaver. It walks through the authorization setup and gives an overview of some of the API endpoints. I also found [this Gist](https://gist.github.com/nielsvanvelzen/ea047d9028f676185832e51ffaf12a6f) that walks through the various Jellyfin API authorization methods. I used these resources to construct a simple curl request:

```bash
TOKEN=example-token-here
BASE_URL=https://jellyfin.example.com

curl -X "GET" \
  "$BASE_URL/Sessions" \
  -H "Authorization: MediaBrowser Token=$TOKEN" |
  jq '.[]'
```

The `TOKEN` value here is a Jellyfin API key from **Admin Dashboard** > **Advanced** > **API Keys**.
The request outputs a JSON object with some playback stats, capabilities, last seen times, etc. Here's the result nicely parsed with `jq`:

```json
{
  "PlayState": {
    ...
  },
  "AdditionalUsers": [],
  "Capabilities": {
    ...
  },
  "RemoteEndPoint": "1.1.1.1",
  "Id": ...,
  "UserId": ...,
  "UserName": "Dan",
  "Client": "Jellyfin Roku",
  "LastActivityDate": "2023-10-29T01:26:17.2969131Z",
  "LastPlaybackCheckIn": "0001-01-01T00:00:00.0000000Z",
  "DeviceName": "50 TCL Roku TV",
  ...
}
```

This is useful stuff, but not exactly the nicely summarized playback information I was hoping for. It's _possible_ to use the REST API to gather all the relevant stats, but it takes multiple API calls to different endpoints. There turned out to be an easier way.

## Fetching aggregate stats

The [Jellyfin Playback Reporting Plugin (PRP)](https://github.com/jellyfin/jellyfin-plugin-playbackreporting) aggregates and exposes playback stats via a dashboard on the Jellyfin admin panel. These stats are stored in a SQLite database in the Jellyfin data directory. Querying this database lets you get basically any playback stats you want. All I had to do is figure out a way to query the database remotely.

Fortunately, installing the PRP also adds dedicated API endpoints at `/user_usage_stats/`. The most useful/relevant of these is the POST endpoint `/user_usage_stats/submit_custom_query`, which lets you pass any arbitrary SQL query to the underlying SQLite database.

After lots of trial and error, I was able to update the curl request to hit the new endpoint:

```bash
curl -X "POST" \
  "$BASE_URL/user_usage_stats/submit_custom_query" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: MediaBrowser Token=$TOKEN" \
  -d '{
    "CustomQueryString": "SELECT * FROM PlaybackActivity LIMIT 2",
    "ReplaceUserId": true
  }' |

  # The extra jq stuff here is just to parse
  # the output into something more readable
  jq '.results | map ({ "date":.[0],
    "user":.[1],
    "item_id":.[2],
    "type":.[3],
    "item_name":.[4],
    "method":.[5],
    "client":.[6],
    "device":.[7],
    "duration":.[8]
  })'
```

Here's what the parsed output looked like:

```json
[
  {
    "DateCreated": "2023-10-29 20:08:19.1115194",
    "UserName": "Dan",
    "ItemId": ...,
    "ItemType": "Movie",
    "ItemName": "She's the Man",
    "PlaybackMethod": "Transcode (v:direct a:aac)",
    "ClientName": "Jellyfin Mobile (iOS)",
    "DeviceName": "iPhone",
    "PlayDuration": "1088"
  },
  {
    "DateCreated": "2023-10-30 22:26:29.7812735",
    "UserName": "Dan",
    "ItemId": ...,
    "ItemType": "Movie",
    "ItemName": "My Neighbor Totoro",
    "PlaybackMethod": "Transcode (v:direct a:aac)",
    "ClientName": "Jellyfin Mobile (iOS)",
    "DeviceName": "iPhone",
    "PlayDuration": "33"
  }
]
```

Note that the test query above just returned a couple arbitrary rows from the `PlaybackActivity` table. I needed a more complicated SQLite query to fetch "live" stats. I came up with the query below, which only returns rows for things that are currently playing and also includes a timestamp for use in Prometheus.

```sql
SELECT
    -- Return the timestamp of the record/stream to
    -- replace the default Prometheus timestamp
    unixepoch(DATETIME(
        DateCreated, "+" || PlayDuration || " seconds"
    )) AS Timestamp,
    UserId,
    ItemType,
    ItemName,
    PlaybackMethod,
    ClientName,
    DeviceName,
    PlayDuration,
    TRUE AS IsActive
FROM PlaybackActivity
-- Only return "active" streams, i.e. ones playing
-- in the last 60 seconds
WHERE DATETIME(DateCreated, "+" || PlayDuration || " seconds") >=
    DATETIME("now", "localtime", "-60 seconds")
```

Hitting the `/user_usage_stats/submit_custom_query` endpoint with this query effectively returns all currently playing Jellyfin media, which is exactly what I needed. The final piece of the puzzle was figuring out how to export the results to Prometheus.

<p class="notice">
If your Grafana instance is on the same machine as Jellyfin, it might be easier to skip Prometheus entirely. Simply use the <a href="https://grafana.com/grafana/plugins/frser-sqlite-datasource/">Grafana SQLite plugin</a> to add the Playback Reporting Plugin database file as a Grafana datasource directly.
</p>

## Prometheus JSON exporter

This part of the project was actually the easiest. I used the community [json_exporter](https://github.com/prometheus-community/json_exporter) to load JSON output from the custom query into Prometheus. I basically just translated the curl request above into a Prometheus [module](https://prometheus.io/docs/guides/multi-target-exporter/#configuring-modules). There are lots of ways to do this, but here's one possible example. Note the comments, they're important:

```yaml
modules:
  jellyfin:
    headers:
      # The Token value here needs to be the API key from the
      # curl request. I hard-coded the value but I'm sure there's
      # a better way
      Authorization: MediaBrowser Token=ADD_TOKEN_HERE
      Content-Type: application/json
      accept: application/json

    # This is the query from above, but condensed to a single line
    # NOTE: The string escaping/lack of newlines is
    # required for the exporter to work
    body:
      content: '{"CustomQueryString": "SELECT unixepoch(DATETIME(DateCreated, \"+\" || PlayDuration || \" seconds\")) AS Timestamp, UserId, ItemType, ItemName, PlaybackMethod, ClientName, DeviceName, PlayDuration, TRUE AS IsActive FROM PlaybackActivity WHERE DATETIME(DateCreated, \"+\" || PlayDuration || \" seconds\") >= DATETIME(\"now\", \"localtime\", \"-60 seconds\")", "ReplaceUserId": true}'

    metrics:
    - name: jellyfin
      type: object
      help: User playback metrics from Jellyfin
      path: '{ .results[*] }'
      # Optionally use the SQL-generated timestamp instead of
      # the Prometheus "query collected at" timestamp
      epochTimestamp: '{ [0] }'
      # The JSON parsing here is basically identical to the jq
      # call above, just using JSONPath syntax instead
      labels:
        user_name: '{ [1] }'
        item_type: '{ [2] }'
        item_name: '{ [3] }'
        playback_method: '{ [4] }'
        client_name: '{ [5] }'
        device_name: '{ [6] }'
      values:
        play_duration: '{ [7] }'
```

Finally, I added the exporter to my Prometheus config file using the [multi-target exporter pattern](https://prometheus.io/docs/guides/multi-target-exporter/) with relabeling and modules:

```yaml
scrape_configs:
  - job_name: json
    metrics_path: /probe
    params:
      module: [jellyfin] # The module from above
    static_configs:
      - targets:
        # The Jellyfin PRP custom query API endpoint
        - https://jellyfin.example.com/user_usage_stats/submit_custom_query
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: HOSTNAME:9115 # The exporter's hostname:port
```

And that's it! A curl request to `http://$HOSTNAME:9115/probe` now returns Prometheus metrics for any currently playing Jellyfin media, along with the user information and transcoding settings of the player. Note that metrics only exist if media _is currently playing_, otherwise the return body will be blank.

Translating the resulting metrics into useable Grafana graphs is a project by itself, but it is possible with the extensive use of transformations. I'll save that topic for a future post.

---

## Update (2024-02-23)

After digging around in the [API docs](https://api.jellyfin.org) for awhile, I realized that using the Playback Reporting Plugin is totally unnecessary. The `Sessions/` endpoint returns everything you need and works more consistently.

The trick is to grab stuff from the `NowPlayingItem` key of each session, which only exists when something is playing. Here's the updated YAML to reflect the new target:

```yaml
modules:
  jellyfin:
    headers:
      Authorization: MediaBrowser Token=ADD_TOKEN_HERE
      Content-Type: application/json
      accept: application/json

    # The body is no longer needed since this is now GET

    # This will return all active sessions regardless of
    # whether something is playing. You can use a combination
    # of label and value filters in Grafana to only get actively
    # playing sessions
    metrics:
    - name: jellyfin
      type: object
      help: User playback metrics from Jellyfin
      # Only look at sessions with the NowPlayingItem key
      path: '{ [?(@.NowPlayingItem)] }'
      labels:
        user_name: '{ .UserName }'
        # Use PromQL label_join and label_replace to concatenate
        # these values into a nice item description
        item_type: '{ .NowPlayingItem.Type }'
        item_name: '{ .NowPlayingItem.Name }'
        item_path: '{ .NowPlayingItem.Path }'
        series_name: '{ .NowPlayingItem.SeriesName }'
        episode_index: 'e{ .NowPlayingItem.IndexNumber }'
        season_index: 's{ .NowPlayingItem.ParentIndexNumber }'
        client_name: '{ .Client }'
        device_name: '{ .DeviceName }'
        # Include the unique session ID in case the above
        # labels aren't a unique combination
        session_id: '{ .Id }'
      values:
        is_paused: '{ .PlayState.IsPaused }'
```

And the Prometheus config:

```yaml
scrape_configs:
  - job_name: json
    metrics_path: /probe
    params:
      module: [jellyfin]
    static_configs:
      - targets:
        # Change the target to point at the sessions endpoint
        - https://jellyfin.example.com/Sessions
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: HOSTNAME:9115
```
