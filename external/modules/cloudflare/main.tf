data "cloudflare_zone" "zone" {
  name = "lorien.cloud"
}

data "cloudflare_api_token_permission_groups" "all" {}

data "http" "public_ipv4" {
  url = "https://ipv4.icanhazip.com"
}

# data "http" "public_ipv6" {
#   url = "https://ipv6.icanhazip.com"
# }

locals {
  public_ips = [
    "${chomp(data.http.public_ipv4.body)}/32",
    # "${chomp(data.http.public_ipv6.body)}/128"
  ]
  public_ip = "${chomp(data.http.public_ipv4.body)}"
}

# Not proxied, not accessible. Just a record for auto-created A by external-dns.
resource "cloudflare_record" "svc" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "A"
  name    = "svc"
  value   = local.public_ip
  proxied = false
  ttl     = 1 # Auto
}

resource "cloudflare_record" "svc_wildcard" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "*.svc"
  value   = "svc.lorien.cloud."
  proxied = false
  ttl     = 1 # Auto
}

# internal resolve
resource "cloudflare_record" "k3s" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "A"
  name    = "k3s"
  value   = "192.168.1.250"
  #value   = local.public_ip
  proxied = false
  ttl     = 1 # Auto
}

resource "cloudflare_record" "k3s_wildcard" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "*.k3s"
  value   = "k3s.lorien.cloud."
  proxied = false
  ttl     = 1 # Auto
}

resource "cloudflare_api_token" "external_dns" {
  name = "k3s_external_dns"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.permissions["DNS Write"]
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }

  condition {
    request_ip {
      in = local.public_ips
    }
  }
}

resource "kubernetes_secret" "external_dns_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "external-dns"
  }

  data = {
    "value" = cloudflare_api_token.external_dns.value
  }
}

resource "cloudflare_api_token" "cert_manager" {
  name = "k3s_cert_manager"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.permissions["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.permissions["DNS Write"]
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }

  condition {
    request_ip {
      in = local.public_ips
    }
  }
}

resource "kubernetes_secret" "cert_manager_token" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }

  data = {
    "api-token" = cloudflare_api_token.cert_manager.value
  }
}
