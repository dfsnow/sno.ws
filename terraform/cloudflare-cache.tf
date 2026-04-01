resource "cloudflare_ruleset" "sno-ws-cache" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  rules = [
    {
      action      = "set_cache_settings"
      description = "Cache static assets"
      enabled     = true
      expression  = "(http.request.uri.path.extension in {\"css\" \"js\"})"

      action_parameters = {
        cache = true
        edge_ttl = {
          mode = "respect_origin"
        }
      }
    },
    {
      action      = "set_cache_settings"
      description = "Cache all served content"
      enabled     = true
      expression  = "(http.request.full_uri wildcard r\"https://content.sno.ws/*\")"

      action_parameters = {
        cache = true
        edge_ttl = {
          mode = "respect_origin"
        }
      }
    },
  ]
}
