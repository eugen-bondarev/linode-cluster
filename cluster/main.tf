
provider "kubernetes" {
  config_path = "${abspath(path.root)}/../cloud/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "${abspath(path.root)}/../cloud/kubeconfig"
    # config_path = "~/.kube/cluster1-kubeconfig"
  }
  experiments {
    manifest = true
  }
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
}

resource "helm_release" "ingress" {
  depends_on = [helm_release.namespaces]
  name       = "ingress"
  chart      = "./apps/ingress"
}


data "kubernetes_service_v1" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress, helm_release.nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "portfolio"
  }
}

# data "kubernetes_ingress_v1" "k8s_ingress" {
#   depends_on = [helm_release.ingress]
#   metadata {
#     name      = "nginx"
#     namespace = "portfolio"
#   }
# }

resource "helm_release" "portfolio" {
  # depends_on = [data.kubernetes_service_v1.ingress_nginx_controller]
  name      = "portfolio"
  chart     = "./apps/portfolio"
  namespace = "portfolio"
  set {
    name  = "host"
    value = data.kubernetes_service_v1.ingress_nginx_controller.status[0]["load_balancer"][0]["ingress"][0]["hostname"]
    # value = data.kubernetes_ingress_v1.k8s_ingress.status.0.load_balancer.0.ingress.0.hostname
    # value = yamldecode(helm_release.ingress.manifest).status.loadBalancer.ingress[0].hostname
  }
}
