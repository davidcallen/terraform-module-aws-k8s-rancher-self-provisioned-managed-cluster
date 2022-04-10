# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : IAM for our Nodes
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "rancher-managed-nodes" {
  name = "${var.environment.resource_name_prefix}-${var.cluster_name}-k8s-rancher-managed-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "rancher-managed-nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.rancher-managed-nodes.name
}
resource "aws_iam_instance_profile" "rancher-managed-nodes" {
  name = "${var.environment.resource_name_prefix}-${var.cluster_name}-k8s-rancher-managed-nodes"
  role = aws_iam_role.rancher-managed-nodes.name
}