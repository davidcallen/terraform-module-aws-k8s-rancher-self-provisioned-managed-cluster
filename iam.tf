# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes : IAM for our Nodes
# ---------------------------------------------------------------------------------------------------------------------
# Note that we RancherServer must allow PassRole in its IAM for rolenames "*-k8s-rancher-managed-nodes" (as below)
# so the rancher-provisioned managed clusters are allow to set an instance profile on themselves.
resource "aws_iam_role" "rancher-managed-nodes" {
  name               = "${var.environment.resource_name_prefix}-${var.cluster_name}-k8s-rancher-managed-nodes"
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
resource "aws_iam_role_policy_attachment" "rancher-managed-nodes-ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.rancher-managed-nodes.name
}

# Policy to allow Node to assume our kubernetes-specifc IAM roles for kube2iam usage.
resource "aws_iam_policy" "rancher-managed-nodes-kube2iam" {
  name        = "${var.environment.resource_name_prefix}-k8s-kube2iam"
  description = "Allow Node to assume certain kubernetes-specifc roles for kube2iam"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeRoles",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${var.environment.account_id}:role/${var.environment.resource_name_prefix}-k8s-kube2iam-*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "rancher-managed-nodes-kube2iam" {
  policy_arn = aws_iam_policy.rancher-managed-nodes-kube2iam.arn
  role       = aws_iam_role.rancher-managed-nodes.name
}

resource "aws_iam_instance_profile" "rancher-managed-nodes" {
  name = "${var.environment.resource_name_prefix}-${var.cluster_name}-k8s-rancher-managed-nodes"
  role = aws_iam_role.rancher-managed-nodes.name
}