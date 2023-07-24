
provider "kubernetes" {
  config_path = "${abspath(path.root)}/secrets/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "${abspath(path.root)}/secrets/kubeconfig"
  }
}

provider "google" {
  project     = "k8s-test-358716"
  region      = "eu-central"
  credentials = "../secrets/google-auth.json"
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

resource "google_dns_managed_zone" "example_zone" {
  depends_on  = [data.kubernetes_service_v1.ingress_nginx_controller]
  name        = "example-zone"
  dns_name    = "eugen-bondarev.com."
  description = "Example DNS zone"
}

resource "google_dns_record_set" "common_dns" {
  for_each = toset([
    "eugen-bondarev.com",
    "metrics.eugen-bondarev.com",
    "pipelines.eugen-bondarev.com",
  ])
  depends_on   = [google_dns_managed_zone.example_zone]
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.example_zone.name
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
    name  = "host"
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

resource "helm_release" "grafana_expose_service" {
  name      = "grafana-expose-service"
  chart     = "./apps/grafana-expose-service"
  namespace = "portfolio"
}

resource "kubernetes_namespace_v1" "jenkins_namespace" {
  metadata {
    name = "jenkins"
    labels = {
      name = "jenkins"
    }
  }
}

resource "helm_release" "jenkins_release" {
  depends_on = [kubernetes_namespace_v1.jenkins_namespace]
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = "jenkins"
}

resource "helm_release" "jenkins_expose_service" {
  name      = "jenkins-expose-service"
  chart     = "./apps/jenkins-expose-service"
  namespace = "portfolio"
}

resource "helm_release" "ingress" {
  depends_on = [
    helm_release.namespaces,
    helm_release.jenkins_expose_service,
    helm_release.grafana_expose_service
  ]
  name      = "ingress"
  chart     = "./apps/ingress"
  namespace = "portfolio"

  set {
    name  = "tls.crt"
    value = base64encode(file("../secrets/tls.crt"))
  }

  set {
    name  = "tls.key"
    value = base64encode(file("../secrets/tls.key"))
  }
}
