resource "kubernetes_cluster_role" "jenkins-cluster-role" {
  metadata {
    name = "jenkins-cr-${var.userName}"
  }

  rule {
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete"
    ]
    resources  = ["deployments"]
    api_groups = ["apps"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins-default-cluster-role-binding" {

  metadata {
    name = "jenkins-crb-${var.userName}-default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins-cluster-role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "jenkins-${var.userName}"
  }
}

resource "kubernetes_cluster_role_binding" "jenkins-cluster-role-binding" {

  metadata {
    name = "jenkins-crb-${var.userName}-provisioned"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins-cluster-role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "jenkins-${var.userName}"
    namespace = "jenkins-${var.userName}"
  }
}