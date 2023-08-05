resource "helm_release" "jenkins" {
  name          = "jenkins"
  repository    = "https://charts.jenkins.io"
  chart         = "jenkins"
  namespace     = "jenkins"
  timeout       = 60 * 10
  recreate_pods = true

  set {
    name = "controller.JCasC.configScripts.welcome-message"
    value = yamlencode({
      jenkins : {
        systemMessage : "Lorem ipsum dolor sit amet 42!"
      }
    })
  }

  set {
    name = "controller.JCasC.configScripts.init-scripts"
    value = yamlencode({
      jobs : [
        {
          script : file("./${path.module}/config/jobs/demo.jenkins")
        }
      ]
    })
  }

  set {
    name  = "controller.adminUser"
    value = var.jenkins.username
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = var.jenkins.password
  }

  set_list {
    name = "controller.installPlugins"
    value = [
      "git:latest",
      "kubernetes:latest",
      "workflow-aggregator:latest",
      "configuration-as-code:latest",
      "job-dsl:latest",
      "blueocean:1.27.5"
    ]
  }
}

resource "helm_release" "jenkins_expose_service" {
  name      = "jenkins-expose-service"
  chart     = "./apps/jenkins-expose-service"
  namespace = "portfolio"
}
