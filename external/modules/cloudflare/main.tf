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


resource "cloudflare_record" "svc_wildcard" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "CNAME"
  name    = "*.svc"
  value   = "svc.lorien.cloud."
# Leave External-DNS to create svc.lorien.cloud entry
  proxied = false
  ttl     = 1 # Auto
}

# internal resolve
resource "cloudflare_record" "k3s" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "A"
  name    = "k3s"
  value   = "192.168.1.250"
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

resource "kubernetes_service_account" "update-ip" {
  metadata {
    name = "update-ip"
    namespace = "external-dns"
  }
  secret {
    name = "${kubernetes_secret.update-ip.metadata.0.name}"
  }
}

resource "kubernetes_secret" "update-ip" {
  metadata {
    name = "update-ip"
  }
}

resource "kubernetes_cluster_role" "update-ip" {
  metadata {
    name = "update-ip"
  }

  rule {
    api_groups = ["extensions","networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "create", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "update-ip" {
  metadata {
    name = "update-ip"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "update-ip"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "update-ip"
    namespace = "external-dns"
  }
}

resource "kubernetes_cron_job_v1" "update-ip" {
  metadata {
    name = "update-ip"
    namespace = "external-dns"
  }
  spec {
    failed_jobs_history_limit     = 3
    successful_jobs_history_limit = 3
    concurrency_policy            = "Replace"
    schedule                      = "*/30 * * * *"
    starting_deadline_seconds     = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            service_account_name = "update-ip"
            container {
              name = "update-ip"
              env {
                name = "IP_HOSTNAME"
                value = "svc.lorien.cloud"
              }
              image = "bitnami/kubectl:1.24.3"
              command = ["/bin/sh",
                         "-c", <<-EOT
                         cat << EOF > /tmp/ingress.yml && kubectl apply -f /tmp/ingress.yml
                         apiVersion: networking.k8s.io/v1
                         kind: Ingress
                         metadata:
                           name: update-ip
                           namespace: external-dns
                           annotations:
                             kubernetes.io/ingress.class: nginx
                             external-dns.alpha.kubernetes.io/hostname: '$IP_HOSTNAME'
                             external-dns.alpha.kubernetes.io/target: '$(curl --silent ifconfig.me)'
                         spec:
                           rules:
                           - host: '$IP_HOSTNAME'
                         EOF
                         cat /tmp/ingress.yml
                         EOT
                        ]
            }
          }
        }
      }
    }
  }
}

