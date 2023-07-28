resource "helm_release" "infrastructure-overview" {
  name          = "infrastructure-overview"
  chart         = "${abspath(path.module)}/charts/app"
  namespace     = "portfolio"
  recreate_pods = true
}
