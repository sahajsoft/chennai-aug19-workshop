resource "kubernetes_storage_class" "ebs_storage_class" {
  metadata {
    name = "ebs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
}

output "storage_class_name" {
  value = kubernetes_storage_class.ebs_storage_class.metadata.0.name
}