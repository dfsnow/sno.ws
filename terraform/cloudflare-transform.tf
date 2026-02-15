resource "cloudflare_ruleset" "sno-ws-transform" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_transform"

  rules {
    action      = "rewrite"
    description = "Redirect /photos/ to CF Images URL"
    enabled     = true
    expression  = "(starts_with(http.request.uri.path, \"/photos\")) and (not (any(http.request.headers[\"via\"][*] contains \"image-resizing\")))"

    action_parameters {
      uri {
        path {
          expression = "wildcard_replace(http.request.uri.path, \"/photos/*/*.*\", \"/cdn-cgi/image/$${1}/photos/$${2}.jpg\")"
        }
      }
    }
  }
}