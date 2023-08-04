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

resource "helm_release" "portfolio" {
  depends_on    = [data.kubernetes_service_v1.ingress_nginx_controller]
  name          = "portfolio"
  chart         = "./apps/portfolio"
  namespace     = "portfolio"
  recreate_pods = true

  set_sensitive {
    name  = "github_key"
    value = base64encode(file("${abspath(path.root)}/secrets/github-key"))
  }

  set_sensitive {
    name  = "github_key_pub"
    value = file("${abspath(path.root)}/secrets/github-key.pub")
  }

  set {
    name  = "host"
    value = "eugen-bondarev.com"
  }

  set {
    name  = "db.name"
    value = var.db.name
  }

  set {
    name  = "db.host"
    value = var.db.host
  }

  set {
    name  = "db.root_password"
    value = var.db.root_password
  }
}

module "infrastructure-overview" {
  depends_on = [kubernetes_namespace_v1.namespaces]
  source     = "./modules/infrastructure-overview"
}
