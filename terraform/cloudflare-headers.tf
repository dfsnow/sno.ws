resource "cloudflare_ruleset" "sno-ws-headers" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "default"
  kind    = "zone"
  phase   = "http_response_headers_transform"

  rules {
    action      = "rewrite"
    description = "Add headers to content R2 bucket"
    enabled     = true
    expression  = "(http.request.full_uri wildcard r\"https://content.sno.ws/*\")"

    action_parameters {
      headers {
        name      = "Cache-Control"
        operation = "add"
        value     = "public, max-age=31536000, immutable"
      }
      headers {
        name      = "Content-Security-Policy"
        operation = "add"
        value     = "default-src 'self'; img-src 'self' *.sno.ws; media-src 'self' *.sno.ws; style-src-attr 'unsafe-inline'; style-src-elem 'self' 'unsafe-inline';"
      }
      headers {
        name      = "Permissions-Policy"
        operation = "add"
        value     = "geolocation=(), midi=(), sync-xhr=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), fullscreen=(), payment=()"
      }
      headers {
        name      = "Referrer-Policy"
        operation = "add"
        value     = "strict-origin-when-cross-origin"
      }
      headers {
        name      = "Strict-Transport-Security"
        operation = "add"
        value     = "max-age=31536000; includeSubDomains"
      }
      headers {
        name      = "X-Content-Type-Options"
        operation = "add"
        value     = "nosniff"
      }
      headers {
        name      = "X-Frame-Options"
        operation = "add"
        value     = "DENY"
      }
      headers {
        name      = "X-XSS-Protection"
        operation = "add"
        value     = "0"
      }
    }
  }

  rules {
    action      = "rewrite"
    description = "Add Content-Disposition header to VCF files"
    enabled     = true
    expression  = "(http.request.uri.path wildcard r\"/*.vcf\")"

    action_parameters {
      headers {
        name      = "Content-Disposition"
        operation = "add"
        value     = "attachment"
      }
    }
  }
}