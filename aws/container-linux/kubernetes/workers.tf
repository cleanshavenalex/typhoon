module "workers" {
  source = "workers"
  name   = "${var.cluster_name}"

  # AWS
  vpc_id          = "${var.vpc_id}"
  subnet_ids      = ["${var.worker_subnets}"]
  worker_subnets  = ["${var.worker_subnets}"]
  security_groups = ["${aws_security_group.worker.id}"]
  count           = "${var.worker_count}"
  instance_type   = "${var.worker_type}"
  os_channel      = "${var.os_channel}"
  disk_size       = "${var.disk_size}"

  # configuration
  kubeconfig            = "${module.bootkube.kubeconfig}"
  ssh_authorized_key    = "${var.ssh_authorized_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  clc_snippets          = "${var.worker_clc_snippets}"
}
