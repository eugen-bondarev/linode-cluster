resource "helm_release" "jenkins" {
  depends_on = [kubernetes_namespace_v1.namespaces]
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = "jenkins"
}

resource "helm_release" "jenkins_expose_service" {
  name      = "jenkins-expose-service"
  chart     = "./apps/jenkins-expose-service"
  namespace = "portfolio"
}
