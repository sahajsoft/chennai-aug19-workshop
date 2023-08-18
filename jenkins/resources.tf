resource "kubernetes_namespace" "jenkins-namespace" {

  metadata {
    name = "jenkins-${var.userName}"
  }

}

resource "random_integer" "jenkins-service-port" {
  min = 5000
  max = 20000
}

resource "helm_release" "jenkins-helm-release" {
  depends_on = [
    kubernetes_cluster_role_binding.jenkins-cluster-role-binding
  ]

  name       = "jenkins-${var.userName}"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins-namespace.metadata[0].name
  atomic     = true
  timeout    = 350

  values = [
    templatefile("jenkins-values.yaml.tpl", {
      namespace : kubernetes_namespace.jenkins-namespace.metadata[0].name
      username : var.userName,
      arch : var.cpuArchitecture,
      servicePort : random_integer.jenkins-service-port.result
    })
  ]

}