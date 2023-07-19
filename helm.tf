provider "helm" {
  kubernetes {
    config_path = "~/.kube/cluster1-kubeconfig"
  }
}

resource "helm_release" "nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "portfolio"
}
