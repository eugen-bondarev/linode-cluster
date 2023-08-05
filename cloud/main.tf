

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.1"
    }
  }

  cloud {
    organization = "eugen-bondarev-private"
    workspaces {
      name = "linode-cloud"
    }
  }
}

provider "linode" {
  token = var.token
}

resource "linode_lke_cluster" "cluster1" {
  k8s_version = "1.26"
  label       = var.label
  region      = var.region
  tags        = var.tags
  pool {
    type  = var.pool.type
    count = var.pool.count
  }
}

output "kubeconfig" {
  value     = linode_lke_cluster.cluster1.kubeconfig
  sensitive = true
}
