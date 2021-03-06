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

output "ssh_key" {
  value       = "${var.ssh_key}"
  description = "Name of the ssh key pair"
}

output "master_subnets" {
  value       = ["${var.master_subnets}"]
  description = "List of master subnet ids"
}

output "worker_subnets" {
  value       = ["${var.worker_subnets}"]
  description = "List of subnet IDs for creating worker instances"
}

output "subnet_ids" {
  value       = ["${var.worker_subnets}"]
  description = "List of subnet IDs for creating worker instances"
}

# output "public_subnets" {
#   value       = ["${aws_subnet.public.*.id}"]
#   description = "List of public subnets for bastion boxes"
# }

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
