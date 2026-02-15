resource "cloudflare_ruleset" "sno-ws-cache" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "default"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  rules {
    action      = "set_cache_settings"
    description = "Cache everything"
    enabled     = true
    expression  = "true"

    action_parameters {
      cache = true
      edge_ttl {
        default = 604800
        mode    = "override_origin"
      }
    }
  }
}
