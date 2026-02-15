resource "cloudflare_r2_bucket" "sno-ws-resources" {
  account_id = var.cloudflare_account_id
  name       = "sno-ws-resources"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "sno-ws-content" {
  account_id = var.cloudflare_account_id
  name       = "sno-ws-content"
  location   = "WNAM"
}