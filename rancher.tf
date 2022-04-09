# Rancher resources

locals {
  rke_network_plugin = var.windows_prefered_cluster ? "flannel" : "canal"
  rke_network_options = var.windows_prefered_cluster ? {
    flannel_backend_port = "4789"
    flannel_backend_type = "vxlan"
    flannel_backend_vni  = "4096"
  } : null
}

# TODO : use new version of rancher2_cluster (with rancher2_machine_config_v2 instead of rancher2_node_template) at some point...

//# Create a new rancher v2 K3S custom Cluster v2 (non-HA)
//resource "rancher2_cluster_v2" "managed-cluster" {
//  # count                                    = (var.kubernetes_distribution == "RKE") ? 1 : 0
//  provider                                 = rancher2.admin
//  name                                     = var.cluster_name
//  kubernetes_version                       = var.kubernetes_version
//  enable_network_policy                    = false
//  default_cluster_role_for_project_members = "user"
////  rke_config {
////    network {
////      plugin  = local.rke_network_plugin
////      options = local.rke_network_options
////    }
////    kubernetes_version = var.kubernetes_version
////  }
//  //  windows_prefered_cluster = var.windows_prefered_cluster
//}
//# Create amazonec2 machine config v2
//resource "rancher2_machine_config_v2" "managed-cluster_rke" {
//  generate_name = "${var.environment.resource_name_prefix}-rancher-managed-cluster"
//  amazonec2_config {
//    ami            = data.aws_ami.ubuntu.id
//    region         = "eu-west-1"
//    security_group = aws_security_group.rancher-managed-cluster.id
//    subnet_id      = var.vpc_private_subnet_ids[0]
//    vpc_id         = var.vpc_id
//    zone           = "a"
//  }
//}

locals {
  aws_zone_letter = substr(var.aws_zone, -1, -1)  # e.g. the last letter of zone like "a"
}
# Create a new rancher2 RKEv1 RKE Cluster
resource "rancher2_cluster" "managed-cluster" {
  provider    = rancher2.admin
  name        = var.cluster_name
  description = "Rancher workload cluster"
  # kind        = "rke"
  rke_config {
    network {
      plugin  = local.rke_network_plugin
      options = local.rke_network_options
    }
    kubernetes_version = var.kubernetes_version
  }
}
# Create a new rancher2 Cloud Credential
resource "rancher2_cloud_credential" "rancher-server-aws-credentials" {
  provider    = rancher2.admin
  name        = "aws-rancher-user"
  description = "AWS credential"
  amazonec2_credential_config {
    access_key     = var.aws_user_credential_access_key
    secret_key     = var.aws_user_credential_secret_key
    default_region = var.aws_region
  }
}
//data "rancher2_cloud_credential" "rancher-server-aws-credentials" {
//  name = var.rancher_server_aws_cloud_credential_name
//}
# Create a new rancher2 RKEv1 Node Template
resource "rancher2_node_template" "managed-cluster" {
  provider            = rancher2.admin
  name                = "${var.environment.resource_name_prefix}-rancher-managed-cluster"
  description         = "Rancher workload cluster"
  cloud_credential_id = rancher2_cloud_credential.rancher-server-aws-credentials.id # data.rancher2_cloud_credential.rancher-server-aws-credentials.id
  engine_install_url = "https://releases.rancher.com/install-docker/${var.docker_version}.sh"
  amazonec2_config {
    # sles-15 fails to start docker service with error :
    #    "unable to configure the Docker daemon with file /etc/docker/daemon.json: the following directives are specified both as a flag and in the configuration file: storage-driver: (from flag: overlay, from file: overlay2)"
    # ami                  = data.aws_ami.sles.id
    #
    ami                  = data.aws_ami.ubuntu.id
    region               = var.aws_region
    security_group       = [aws_security_group.rancher-managed-cluster.name]
    subnet_id            = var.vpc_private_subnet_ids[0]
    vpc_id               = var.vpc_id
    zone                 = local.aws_zone_letter
    ssh_user             = "ubuntu"    # Note : "ec2-user" - for sles
    # There seems to be is an issue with specifying an SSH Key - get error :
    #  "Error setting machine configuration from flags provided: using --amazonec2-keypair-name also requires --amazonec2-ssh-keypath:Timeout waiting for ssh key"
    # keypair_name         = var.cluster_ssh_key_name
    # ssh_keypath          = "/home/ec2-user/.ssh/id_rsa" # var.cluster_ssh_private_key_filename
    instance_type        = var.ec2_instance_type
    private_address_only = true
  }
}
# Create a new rancher2 RKEv1 Node Pool
resource "rancher2_node_pool" "foo" {
  provider         = rancher2.admin
  cluster_id       = rancher2_cluster.managed-cluster.id
  name             = "${var.environment.resource_name_prefix}-rancher-managed-cluster"
  hostname_prefix  = "rancher-cluster-0"
  node_template_id = rancher2_node_template.managed-cluster.id
  quantity         = 1
  control_plane    = true
  etcd             = true
  worker           = true
}