variable "db" {
  description = "Desired database credentials. (required)"
  type = object({
    host          = string
    name          = string
    root_password = string
  })
}

variable "jenkins" {
  description = "Desired jenkins credentials. (required)"
  type = object({
    username = string
    password = string
  })
}
