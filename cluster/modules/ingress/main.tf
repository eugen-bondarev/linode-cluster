resource "helm_release" "nginx" {
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
  name      = "ingress"
  chart     = "./${path.module}/chart"
  namespace = "portfolio"

  set_sensitive {
    name  = "tls.crt"
    value = base64encode(file("${abspath(path.root)}/secrets/tls.crt"))
  }

  set_sensitive {
    name  = "tls.key"
    value = base64encode(file("${abspath(path.root)}/secrets/tls.key"))
  }
}

data "kubernetes_service_v1" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress, helm_release.nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "portfolio"
  }
}

resource "google_dns_record_set" "common_dns" {
  for_each = toset([
    "eugen-bondarev.com",
    "metrics.eugen-bondarev.com",
    "pipelines.eugen-bondarev.com",
    "infrastructure.eugen-bondarev.com",
  ])
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  managed_zone = "default-zone"
  rrdatas      = [data.kubernetes_service_v1.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.ip]
}
