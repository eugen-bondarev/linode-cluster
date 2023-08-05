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
  chart     = "./${path.module}/chart"
  namespace = "portfolio"
}
