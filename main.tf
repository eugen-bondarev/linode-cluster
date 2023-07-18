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

resource "linode_nodebalancer" "cluster1_main_nodebalancer" {
  region = var.region
  label  = "cluster1_main_nodebalancer"
}

resource "linode_nodebalancer_config" "cluster1_main_nodebalancer_config_http" {
  nodebalancer_id = linode_nodebalancer.cluster1_main_nodebalancer.id
  port            = 80
  protocol        = "http"
}

resource "linode_nodebalancer_config" "cluster1_main_nodebalancer_config_https" {
  nodebalancer_id = linode_nodebalancer.cluster1_main_nodebalancer.id
  port            = 443
  protocol        = "http"
}

// Export this cluster's attributes
output "kubeconfig" {
  value     = linode_lke_cluster.cluster1.kubeconfig
  sensitive = true
}

output "api_endpoints" {
  value = linode_lke_cluster.cluster1.api_endpoints
}

output "nodebalancer_ip" {
  value = linode_nodebalancer.cluster1_main_nodebalancer.ipv4
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
