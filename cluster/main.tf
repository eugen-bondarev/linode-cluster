
provider "kubernetes" {
  config_path = "${abspath(path.root)}/../cloud/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "${abspath(path.root)}/../cloud/kubeconfig"
    # config_path = "~/.kube/cluster1-kubeconfig"
  }
  # experiments {
  #   manifest = true
  # }
}

resource "helm_release" "namespaces" {
  name  = "namespaces"
  chart = "./apps/namespaces"
}

resource "helm_release" "nginx" {
  depends_on = [helm_release.namespaces]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "portfolio"
  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "portfolio/tls"
  }
}

resource "helm_release" "ingress" {
  depends_on = [helm_release.namespaces]
  name       = "ingress"
  chart      = "./apps/ingress"
  namespace  = "portfolio"

  set {
    name  = "tls.crt"
    value = base64encode(file("../secrets/tls.crt"))
  }

  set {
    name  = "tls.key"
    value = base64encode(file("../secrets/tls.key"))
  }
}

provider "google" {
  project     = "k8s-test-358716"
  region      = "eu-central"
  credentials = "../secrets/google-auth.json"
}

resource "google_dns_managed_zone" "example_zone" {
  depends_on  = [data.kubernetes_service_v1.ingress_nginx_controller]
  name        = "example-zone"
  dns_name    = "eugen-bondarev.com."
  description = "Example DNS zone"
}

resource "google_dns_record_set" "dns_set" {
  depends_on   = [google_dns_managed_zone.example_zone]
  name         = "eugen-bondarev.com."
  type         = "A"
  ttl          = 300
  managed_zone = "example-zone"
  rrdatas      = [data.kubernetes_service_v1.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.ip]
}

data "kubernetes_service_v1" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress, helm_release.nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "portfolio"
  }
}

resource "helm_release" "portfolio" {
  depends_on    = [data.kubernetes_service_v1.ingress_nginx_controller]
  name          = "portfolio"
  chart         = "./apps/portfolio"
  namespace     = "portfolio"
  recreate_pods = true

  set {
    name  = "github_key"
    value = base64encode(file("../secrets/github-key"))
  }

  set {
    name  = "github_key_pub"
    value = file("../secrets/github-key.pub")
  }

  set {
    name = "host"
    # value = data.kubernetes_service_v1.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    value = "eugen-bondarev.com"
  }

  set {
    name  = "db.name"
    value = var.db.name
  }

  set {
    name  = "db.host"
    value = var.db.host
  }

  set {
    name  = "db.root_password"
    value = var.db.root_password
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "metrics"
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "metrics"
}

output "test" {
  value = helm_release.portfolio.manifest
}
