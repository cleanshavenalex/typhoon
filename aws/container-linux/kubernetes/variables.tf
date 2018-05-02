variable "cluster_name" {
  type        = "string"
  description = "Unique cluster name (prepended to dns_zone)"
}

# AWS

variable "vpc_id" {
  type        = "string"
  description = "ID of the AWS VPC"
}

variable "route_table_id" {
  type        = "string"
  description = "ID of the route table for the existing VPC."
}

variable "internet_gateway" {
  type        = "string"
  description = "ID of the internet gateway in the pre-existing VPC"
}

variable "vpn_security_group" {
  type        = "string"
  description = "Security Group ID of the VPN."
}

variable "dns_zone" {
  type        = "string"
  description = "AWS Route53 DNS Zone (e.g. aws.example.com)"
}

variable "public_zone_id" {
  type        = "string"
  description = "AWS Route53 Public DNS ZONE ID"
}

variable "dns_zone_id" {
  type        = "string"
  description = "AWS Route53 DNS Zone ID (e.g. Z3PAABBCFAKEC0)"
}

variable "elb_ssl_certificate_id" {
  type        = "string"
  description = "ID of the security certificate associated with the load balancer"
}

variable "ssl_cert_file" {
  type        = "string"
  description = "Local path to the folder where the cert, fullchain, chain, and privkey are for the cluster domain"
}

# instances

variable "controller_count" {
  type        = "string"
  default     = "1"
  description = "Number of controllers (i.e. masters)"
}

variable "controller_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type for controllers"
}

variable "worker_count" {
  type        = "string"
  default     = "1"
  description = "Number of workers"
}

variable "worker_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type for workers"
}

variable "etcd_count" {
  type        = "string"
  default     = "1"
  description = "Number of etcd nodes"
}

variable "etcd_type" {
  type        = "string"
  default     = "1"
  description = "EC2 instance type for etcd"
}

variable "os_channel" {
  type        = "string"
  default     = "stable"
  description = "Container Linux AMI channel (stable, beta, alpha)"
}

variable "disk_size" {
  type        = "string"
  default     = "40"
  description = "Size of the EBS volume in GB"
}

variable "master_volume_size" {
  type        = "string"
  default     = 64
  description = "RAM for each master node"
}

variable "controller_clc_snippets" {
  type        = "list"
  description = "Controller Container Linux Config snippets"
  default     = []
}

variable "worker_clc_snippets" {
  type        = "list"
  description = "Worker Container Linux Config snippets"
  default     = []
}

# configuration

variable "ssh_key" {
  type        = "string"
  description = "Name of ssh key"
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "networking" {
  description = "Choice of networking provider (calico or flannel)"
  type        = "string"
  default     = "calico"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only). Use 8981 if using instances types with Jumbo frames."
  type        = "string"
  default     = "1480"
}

variable "host_cidr" {
  description = "CIDR IPv4 range to assign to EC2 nodes"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = "string"
  description = "CIDR for the public subnet. Used by the Bastion host"
  default     = "10.2.0.0/16"
}

variable "pod_cidr" {
  description = "CIDR IPv4 range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IPv4 range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD

  type    = "string"
  default = "10.3.0.0/16"
}

variable "cluster_domain_suffix" {
  description = "Queries for domains with the suffix will be answered by kube-dns. Default is cluster.local (e.g. foo.default.svc.cluster.local) "
  type        = "string"
  default     = "cluster.local"
}

variable "master_subnets" {
  type = "list"
}

variable "worker_subnets" {
  type = "list"
}

variable "master_azs" {
  type = "list"
}

variable "worker_azs" {
  type = "list"
}

variable "private_master_endpoints" {
  description = "If set to true, private-facing ingress resources are created."
  default     = true
}

variable "public_master_endpoints" {
  description = "If set to true, public-facing ingress resources are created."
  default     = true
}

variable "custom_dns_name" {
  type        = "string"
  default     = ""
  description = "DNS prefix used to construct the console and API server endpoints."
}

variable "bastion_pem_path" {
  type        = "string"
  description = "path to the bastion pem file"
}

variable "bastion_security_group" {
  type        = "string"
  description = "Pre-existing security group for the bastion host."
}
