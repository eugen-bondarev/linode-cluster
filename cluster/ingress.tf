resource "helm_release" "nginx" {
  depends_on = [kubernetes_namespace_v1.namespaces]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "portfolio"
  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "portfolio/tls"
  }
}

resource "google_dns_managed_zone" "default_zone" {
  depends_on = [data.kubernetes_service_v1.ingress_nginx_controller]
  name       = "default-zone"
  dns_name   = "eugen-bondarev.com."
}

resource "google_dns_record_set" "common_dns" {
  for_each = toset([
    "eugen-bondarev.com",
    "metrics.eugen-bondarev.com",
    "pipelines.eugen-bondarev.com",
  ])
  depends_on   = [google_dns_managed_zone.default_zone]
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.default_zone.name
  rrdatas      = [data.kubernetes_service_v1.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.ip]
}

data "kubernetes_service_v1" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress, helm_release.nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "portfolio"
  }
}

resource "helm_release" "ingress" {
  depends_on = [kubernetes_namespace_v1.namespaces]
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
