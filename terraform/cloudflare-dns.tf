resource "cloudflare_zone" "sno-ws" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "sno.ws"
}

resource "cloudflare_zone_setting" "sno-ws-always-use-https" {
  zone_id    = cloudflare_zone.sno-ws.id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_zone_setting" "sno-ws-automatic-https-rewrites" {
  zone_id    = cloudflare_zone.sno-ws.id
  setting_id = "automatic_https_rewrites"
  value      = "on"
}

resource "cloudflare_zone_setting" "sno-ws-email-obfuscation" {
  zone_id    = cloudflare_zone.sno-ws.id
  setting_id = "email_obfuscation"
  value      = "off"
}

resource "cloudflare_zone_setting" "sno-ws-image-resizing" {
  zone_id    = cloudflare_zone.sno-ws.id
  setting_id = "image_resizing"
  value      = "on"
}

resource "cloudflare_zone_setting" "sno-ws-ssl" {
  zone_id    = cloudflare_zone.sno-ws.id
  setting_id = "ssl"
  value      = "strict"
}

resource "cloudflare_zone_setting" "sno-ws-tls-1-3" {
  zone_id    = cloudflare_zone.sno-ws.id
  setting_id = "tls_1_3"
  value      = "on"
}

# content.sno.ws CNAME is managed by R2 custom domain (read-only)
# A records are managed separately

# Main domain records
resource "cloudflare_dns_record" "sno-ws-main" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "sno.ws"
  type    = "CNAME"
  content = "sno-ws.pages.dev"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "sno-ws-www" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "www"
  type    = "CNAME"
  content = "sno-ws.pages.dev"
  proxied = true
  ttl     = 1
}

# Fastmail DKIM records
resource "cloudflare_dns_record" "sno-ws-fm1" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "fm1._domainkey"
  type    = "CNAME"
  content = "fm1.sno.ws.dkim.fmhosted.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "sno-ws-fm2" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "fm2._domainkey"
  type    = "CNAME"
  content = "fm2.sno.ws.dkim.fmhosted.com"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "sno-ws-fm3" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "fm3._domainkey"
  type    = "CNAME"
  content = "fm3.sno.ws.dkim.fmhosted.com"
  proxied = false
  ttl     = 1
}

# Fastmail MX records
resource "cloudflare_dns_record" "sno-ws-mx1-root" {
  zone_id  = cloudflare_zone.sno-ws.id
  name     = "sno.ws"
  type     = "MX"
  content  = "in1-smtp.messagingengine.com"
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "sno-ws-mx2-root" {
  zone_id  = cloudflare_zone.sno-ws.id
  name     = "sno.ws"
  type     = "MX"
  content  = "in2-smtp.messagingengine.com"
  priority = 20
  ttl      = 1
}

resource "cloudflare_dns_record" "sno-ws-mx1-wildcard" {
  zone_id  = cloudflare_zone.sno-ws.id
  name     = "*"
  type     = "MX"
  content  = "in1-smtp.messagingengine.com"
  priority = 10
  ttl      = 1
}

resource "cloudflare_dns_record" "sno-ws-mx2-wildcard" {
  zone_id  = cloudflare_zone.sno-ws.id
  name     = "*"
  type     = "MX"
  content  = "in2-smtp.messagingengine.com"
  priority = 20
  ttl      = 1
}

# Email authentication records
resource "cloudflare_dns_record" "sno-ws-spf" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "sno.ws"
  type    = "TXT"
  content = "v=spf1 include:spf.messagingengine.com ?all"
  ttl     = 1
}

resource "cloudflare_dns_record" "sno-ws-dmarc" {
  zone_id = cloudflare_zone.sno-ws.id
  name    = "_dmarc"
  type    = "TXT"
  content = "v=DMARC1;p=none;rua=mailto:${var.dmarc_rua}"
  ttl     = 1
}
