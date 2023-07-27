resource "helm_release" "jenkins" {
  depends_on    = [kubernetes_namespace_v1.namespaces]
  name          = "jenkins"
  repository    = "https://charts.jenkins.io"
  chart         = "jenkins"
  namespace     = "jenkins"
  timeout       = 60 * 10
  recreate_pods = true

  values = [
    file("./pipelines.test.yaml")
  ]

  set {
    name = "controller.JCasC.configScripts.welcome-message"
    value = jsonencode({
      jenkins: {
        systemMessage: "Lorem ipsum dolor sit amet 42!"
      }
    })
  }
}

resource "helm_release" "jenkins_expose_service" {
  name      = "jenkins-expose-service"
  chart     = "./apps/jenkins-expose-service"
  namespace = "portfolio"
}
