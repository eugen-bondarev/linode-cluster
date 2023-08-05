variable "jenkins" {
  description = "Desired jenkins credentials. (required)"
  type = object({
    username = string
    password = string
  })
}
