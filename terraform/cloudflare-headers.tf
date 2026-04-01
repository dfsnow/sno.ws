resource "cloudflare_ruleset" "sno-ws-headers" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "default"
  kind    = "zone"
  phase   = "http_response_headers_transform"

  rules = [
    {
      action      = "rewrite"
      description = "Add headers to content R2 bucket"
      enabled     = true
      expression  = "(http.request.full_uri wildcard r\"https://content.sno.ws/*\")"

      action_parameters = {
        headers = {
          "Cache-Control" = {
            operation = "add"
            value     = "public, max-age=31536000, immutable"
          }
          "Content-Security-Policy" = {
            operation = "add"
            value     = "default-src 'self'; img-src 'self' *.sno.ws; media-src 'self' *.sno.ws; style-src-attr 'unsafe-inline'; style-src-elem 'self' 'unsafe-inline';"
          }
          "Permissions-Policy" = {
            operation = "add"
            value     = "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(), payment=()"
          }
          "Referrer-Policy" = {
            operation = "add"
            value     = "strict-origin-when-cross-origin"
          }
          "Strict-Transport-Security" = {
            operation = "add"
            value     = "max-age=31536000; includeSubDomains"
          }
          "X-Content-Type-Options" = {
            operation = "add"
            value     = "nosniff"
          }
          "X-Frame-Options" = {
            operation = "add"
            value     = "DENY"
          }
          "X-XSS-Protection" = {
            operation = "add"
            value     = "0"
          }
        }
      }
    },
    {
      action      = "rewrite"
      description = "Add Content-Disposition header to VCF files"
      enabled     = true
      expression  = "(http.request.uri.path wildcard r\"/*.vcf\")"

      action_parameters = {
        headers = {
          "Content-Disposition" = {
            operation = "add"
            value     = "attachment"
          }
        }
      }
    },
  ]
}
