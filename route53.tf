resource "aws_route53_record" "managed-cluster" {
  count           = (length(var.cluster_dns) > 0) ? 1 : 0
  name            = var.cluster_dns
  zone_id         = var.route53_private_hosted_zone_id
  records         = [data.aws_instance.managed-cluster.private_ip] #["rancher.${var.environment.name}.${var.org_domain}"]
  ttl             = 60
  type            = "A"
  allow_overwrite = true
}
data "aws_instance" "managed-cluster" {
  instance_tags = {
    Name = "rancher-cluster-0"
  }
}