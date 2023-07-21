variable "db" {
  description = "Desired database credentials. (required)"
  type = object({
    host          = string
    name          = string
    root_password = string
  })
}
