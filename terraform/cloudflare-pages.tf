resource "cloudflare_pages_project" "sno-ws" {
  account_id        = var.cloudflare_account_id
  name              = "sno-ws"
  production_branch = "master"

  source {
    type = "github"
    config {
      owner                         = "dfsnow"
      repo_name                     = "sno.ws"
      production_branch             = "master"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
    }
  }

  build_config {
    build_command   = "hugo"
    destination_dir = "public"
  }

  deployment_configs {
    production {
      compatibility_date = "2025-10-10"
      fail_open          = true
      usage_model        = "standard"
      environment_variables = {
        HUGO_VERSION = "0.154.0"
      }
    }
    preview {
      compatibility_date = "2025-10-10"
      fail_open          = true
      usage_model        = "standard"
    }
  }
}

resource "cloudflare_pages_domain" "sno-ws" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.sno-ws.name
  domain       = "sno.ws"
}
