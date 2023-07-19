variable "token" {
  description = "API Token. (required)"
}

variable "root_password" {
  description = "Pass. (required)"
}

variable "k8s_version" {
  description = "The Kubernetes version to use for this cluster. (required)"
  default     = "1.26"
}

variable "label" {
  description = "The unique label to assign to this cluster. (required)"
  default     = "cluster1"
}

variable "region" {
  description = "The region where your cluster will be located. (required)"
  default     = "eu-central"
}

variable "tags" {
  description = "Tags to apply to your cluster for organizational purposes. (optional)"
  type        = list(string)
  default     = []
}

variable "pools" {
  description = "The Node Pool specifications for the Kubernetes cluster. (required)"
  type = list(object({
    type  = string
    count = number
  }))
  default = [
    {
      type  = "g6-standard-1"
      count = 4
    }
  ]
}
