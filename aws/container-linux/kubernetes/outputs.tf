output "ingress_dns_name" {
  value       = "${module.workers.ingress_dns_name}"
  description = "DNS name of the network load balancer for distributing traffic to Ingress controllers"
}

# output "bastion_ip" {
#   value       = "${module.bastions.bastion_ip}"
#   description = "IP of the bastion host"
# }

# Outputs for worker pools

output "vpc_id" {
  value       = "${var.vpc_id}"
  description = "ID of the VPC for creating worker instances"
}

output "cluster_name" {
  value       = "${var.cluster_name}"
  description = "Cluster Name"
}

output "dns_zone" {
  value       = "${var.dns_zone}"
  description = "DNS Zone to pass to workers module"
}

output "ssh_key" {
  value       = "${var.ssh_key}"
  description = "Name of the ssh key pair"
}

output "master_subnets" {
  value       = ["${var.master_subnets}"]
  description = "List of master subnet ids"
}

output "controller_security_groups" {
  value = ["${aws_security_group.controller.id}"]
}

output "worker_subnets" {
  value       = ["${var.worker_subnets}"]
  description = "List of subnet IDs for creating worker instances"
}

output "subnet_ids" {
  value       = ["${var.worker_subnets}"]
  description = "List of subnet IDs for creating worker instances"
}

output "dns_zone_id" {
  value       = "${var.dns_zone_id}"
  description = "DNS Zone ID to pass to workers load balancer"
}

output "worker_security_groups" {
  value       = ["${aws_security_group.worker.id}"]
  description = "List of worker security group IDs"
}

output "security_groups" {
  value       = ["${aws_security_group.worker.id}"]
  description = "List of worker security group IDs"
}

# output "bastion_security_groups" {
#   value       = ["${aws_security_group.bastion.id}"]
#   description = "List of bastion security group IDs"
# }

output "kubeconfig" {
  value = "${module.bootkube.kubeconfig}"
}
