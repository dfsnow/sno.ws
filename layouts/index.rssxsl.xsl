{{- $pctx := . -}}
{{- if .IsHome -}}
    {{ $pctx = .Site }}
{{- end -}}
{{- $pages := slice -}}
{{- if or $.IsHome $.IsSection -}}
    {{- $pages = $pctx.RegularPages -}}
{{- else -}}
    {{- $pages = $pctx.Pages -}}
{{- end -}}
{{- $main_css := resources.Get "css/main.scss" | toCSS | minify | fingerprint -}}
{{- printf "<?xml version=\"1.0\" encoding=\"utf-8\"?>" | safeHTML -}}
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom">
    <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
        <head>
            <title>{{ .Site.Title }} | RSS Feed</title>
            <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
            <link rel="stylesheet" href="{{- $main_css.Permalink -}}"/>
        </head>
        <body>
            <main class="content">
                <h4 style="margin:0.6125em 0;line-height:1.5;">
                    This is an RSS feed of all major posts. Visit
                    <a href="https://aboutfeeds.com">About Feeds</a>
                    to learn more and get started using an RSS reader.
                    I recommend <a href="https://netnewswire.com">NetNewsWire</a>
                    and/or <a href="https://freshrss.org">FreshRSS</a>.
                </h4>
                <div id="writing" class="post-list">
                {{- range where (where $pages ".Params.link" "==" nil) ".Params.date" "!=" nil -}}
                    {{- if or (gt (len .Content) 0) (isset .Params "src") -}}
                    <div class="post-list-info">
                        <a href="{{- .Permalink -}}">{{- .Title -}}</a>
                    </div>
                    <time class="post-list-date" datetime='{{- .Date.Format "2006-01-02" -}}'>{{- .Date.Format "2006-01-02" -}}</time>
                    <div class="post-list-misc">
                        {{- if eq .Params.recommended "true" -}}
                        {{- partial "heart" (dict "title" "Personal favorite" "width" $.Site.Params.heartSize "height" $.Site.Params.heartSize ) -}}
                        {{- end -}}
                    </div>
                    {{- end -}}
                {{- end -}}
                </div>
            </main>
        </body>
    </html>
    </xsl:template>
</xsl:stylesheet>