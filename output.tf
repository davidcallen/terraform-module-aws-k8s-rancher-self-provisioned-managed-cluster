output "custom_cluster_command" {
  value       = rancher2_cluster.managed-cluster.cluster_registration_token.0.node_command
  description = "Docker command used to add a node to the quickstart cluster"
}
output "custom_cluster_windows_command" {
  value       = rancher2_cluster.managed-cluster.cluster_registration_token.0.windows_node_command
  description = "Docker command used to add a windows node to the quickstart cluster"
}
output "cluster_endpoint" {
  value = rancher2_cluster.managed-cluster.cluster_auth_endpoint
}
output "cluster_host" {
  value = yamldecode(rancher2_cluster.managed-cluster.kube_config)["clusters"][0]["cluster"]["server"]
}
output "cluster_ca_certificate" {
  value = yamldecode(rancher2_cluster.managed-cluster.kube_config)["clusters"][0]["cluster"]["certificate-authority-data"]
  # value = rancher2_cluster.managed-cluster.ca_cert
}
output "token" {
  # value = rancher2_cluster.managed-cluster.kube_config cluster_registration_token
  value = yamldecode(rancher2_cluster.managed-cluster.kube_config)["users"][0]["user"]["token"]
}
//output "workload_node_ip" {
//  value = aws_instance.rancher-managed-cluster.private_ip
//}