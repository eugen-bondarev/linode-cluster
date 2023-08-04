terraform {

  cloud {
    organization = "eugen-bondarev-private"
    workspaces {
      name = "linode-cluster"
    }
  }
}

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
  credentials = "${abspath(path.root)}/secrets/google-auth.json"
}

resource "kubernetes_namespace_v1" "namespaces" {
  for_each = toset([
    "jenkins",
    "portfolio",
    "metrics"
  ])
  metadata {
    name = each.value
    labels = {
      name = each.value
    }
  }
}

module "portfolio" {
  depends_on = [kubernetes_namespace_v1.namespaces]
  source     = "./modules/portfolio"
  db         = var.db
}

module "infrastructure-overview" {
  depends_on = [kubernetes_namespace_v1.namespaces]
  source     = "./modules/infrastructure-overview"
}
