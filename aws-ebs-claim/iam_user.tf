resource "aws_iam_user" "ebs_csi_driver" {
  name = "ebs-csi-driver"
  path = "/sadhak/"
}

resource "aws_iam_user_policy_attachment" "ebs_csi_driver_managed_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  user       = aws_iam_user.ebs_csi_driver.name
}

resource "aws_iam_access_key" "ebs_csi_driver_access_keys" {
  depends_on = [aws_iam_user_policy_attachment.ebs_csi_driver_managed_policy_attachment]
  user       = aws_iam_user.ebs_csi_driver.name
}