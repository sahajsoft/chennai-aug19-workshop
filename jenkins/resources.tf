resource "kubernetes_namespace" "jenkins-namespace" {

  metadata {
    name = "jenkins-${var.userName}"
  }

}

resource "kubernetes_persistent_volume_claim" "jenkins-pvc-claim" {
  metadata {
    name      = "jenkins-pvc-${var.userName}}"
    namespace = kubernetes_namespace.jenkins-namespace.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
    storage_class_name = "ebs"
  }
}

resource "helm_release" "jenkins-helm-release" {
  depends_on = [kubernetes_persistent_volume_claim.jenkins-pvc-claim]

  name       = "jenkins-${var.userName}"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins-namespace.metadata[0].name
  atomic     = true
  timeout    = 300

  values = [
    templatefile("jenkins-values.yaml.tpl", {
      pvcClaimName : kubernetes_persistent_volume_claim.jenkins-pvc-claim.metadata[0].name,
      namespace    : kubernetes_namespace.jenkins-namespace.metadata[0].name
    })
  ]

}