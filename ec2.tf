locals {
  node_username = "ec2-user"
}
data "tls_public_key" "ssh-key" {
  private_key_pem = file(var.cluster_ssh_private_key_filename)
}

# Security group to allow all traffic
resource "aws_security_group" "rancher-managed-cluster" {
  name        = "${var.environment.resource_name_prefix}-rancher-managed-cluster"
  description = "Rancher managed (workload) cluster"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = var.cluster_ingress_allowed_cidrs
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.global_default_tags, {
    Name = "${var.environment.resource_name_prefix}-rancher-managed-cluster"
  })
}