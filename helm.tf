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

resource "helm_release" "portfolio" {
  name      = "portfolio"
  chart     = "./apps/portfolio"
  namespace = "portfolio"
  set {
    name  = "host"
    value = "http://139-144-161-5.ip.linodeusercontent.com"
  }
}
