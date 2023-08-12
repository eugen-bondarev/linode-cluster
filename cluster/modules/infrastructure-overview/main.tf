resource "helm_release" "infrastructure-overview" {
  name          = "infrastructure-overview"
  chart         = "./${path.module}/charts/app"
  namespace     = "portfolio"
  recreate_pods = true
  set {
    name  = "appVersion"
    value = var.appVersion
  }
}

output "appVersion" {
  value = var.appVersion
}
