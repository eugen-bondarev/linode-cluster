terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.1"
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

  dynamic "pool" {
    for_each = var.pools
    content {
      type  = pool.value["type"]
      count = pool.value["count"]
    }
  }
}

// Export this cluster's attributes
output "kubeconfig" {
  value     = linode_lke_cluster.cluster1.kubeconfig
  sensitive = true
}

output "api_endpoints" {
  value = linode_lke_cluster.cluster1.api_endpoints
}

output "status" {
  value = linode_lke_cluster.cluster1.status
}

output "id" {
  value = linode_lke_cluster.cluster1.id
}

output "pool" {
  value = linode_lke_cluster.cluster1.pool
}
