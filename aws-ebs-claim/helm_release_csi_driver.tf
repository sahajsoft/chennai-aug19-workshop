resource "helm_release" "ebs_csi_driver" {
  chart            = "aws-ebs-csi-driver"
  name             = "ebs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  namespace        = "aws"
  version          = "2.18.0"
  create_namespace = true
  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      awsAccessKey : aws_iam_access_key.ebs_csi_driver_access_keys.id,
      awsSecretKey : aws_iam_access_key.ebs_csi_driver_access_keys.secret
    })
  ]
}