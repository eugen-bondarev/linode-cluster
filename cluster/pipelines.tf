resource "helm_release" "jenkins" {
  depends_on    = [kubernetes_namespace_v1.namespaces]
  name          = "jenkins"
  repository    = "https://charts.jenkins.io"
  chart         = "jenkins"
  namespace     = "jenkins"
  timeout       = 60 * 10
  recreate_pods = true

  # values = [
  #   file("./pipelines.test.yaml")
  # ]

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
      jobs: [
        {
          script: file("./job-test.jenkins")
        }
      ]
    })
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
