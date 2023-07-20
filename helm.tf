


provider "helm" {
  kubernetes {
    config_path = "${abspath(path.root)}/kubeconfig"
    # config_path = "~/.kube/cluster1-kubeconfig"
  }
}

resource "helm_release" "namespaces" {
  depends_on = [linode_lke_cluster.cluster1]
  name       = "namespaces"
  chart      = "./apps/namespaces"
}

resource "helm_release" "nginx" {
  depends_on = [helm_release.namespaces]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "portfolio"
}

resource "helm_release" "portfolio" {
  depends_on = [helm_release.namespaces]
  name       = "portfolio"
  chart      = "./apps/portfolio"
  namespace  = "portfolio"
  set {
    name  = "host"
    value = "http://139-144-161-5.ip.linodeusercontent.com"
  }
}
