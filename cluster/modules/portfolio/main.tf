resource "helm_release" "portfolio" {
  name          = "portfolio"
  chart         = "./${path.module}/chart"
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

  set_sensitive {
    name  = "db.root_password"
    value = var.db.root_password
  }
}
