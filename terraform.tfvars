label       = "cluster1"
k8s_version = "1.26"
region      = "eu-central"
pools = [
  {
    type  = "g6-standard-1"
    count = 4
  }
]
