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
  protocol        = "tcp"
}

# resource "linode_nodebalancer_config" "cluster1_main_nodebalancer_config_https" {
#   nodebalancer_id = linode_nodebalancer.cluster1_main_nodebalancer.id
#   port            = 443
#   protocol        = "http"
# }


# resource "linode_instance" "instance" {
#   count      = 1
#   label      = "instance-${count.index + 1}"
#   group      = "nodebalancer"
#   region     = var.region
#   type       = "g6-nanode-1"
#   image      = "linode/ubuntu20.04"
#   root_pass  = var.root_password
#   private_ip = true
# }

data "linode_instances" "k8s_instances" {
  filter {
    name = "tags"
    values = var.tags
    # values = [
    #   "lke119841-177551-64b6f78cd5c4",
    #   "lke119841-177551-64b6f78d36cd",
    #   "lke119841-177551-64b6f78d936a",
    #   "lke119841-177551-64b6f78df2c7"
    # ]
  }
}


resource "linode_nodebalancer_node" "nodebalancer-node" {
  count           = 4
  nodebalancer_id = linode_nodebalancer.cluster1_main_nodebalancer.id
  config_id       = linode_nodebalancer_config.cluster1_main_nodebalancer_config_http.id
  label           = element(data.linode_instances.k8s_instances.instances.*.label, count.index)
  address = "${
    element(data.linode_instances.k8s_instances.instances.*.private_ip_address, count.index)
    }:${30177
  }"
  mode = "accept"
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
