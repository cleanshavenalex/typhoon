# Controller instances
resource "aws_instance" "controllers" {
  count = "${var.controller_count}"

  tags = {
    Name = "${var.cluster_name}-controller-${count.index}"
  }

  instance_type = "${var.controller_type}"
  key_name      = "${var.ssh_key}"
  ami           = "${data.aws_ami.coreos.image_id}"
  user_data     = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"

  # storage
  root_block_device {
    volume_type = "io1"
    iops        = "1000"
    volume_size = "100"
  }

  # network
  associate_public_ip_address = false

  subnet_id              = "${var.master_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.controller.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }
}

variable "master_label" {
  default = "--node-labels=node-role.kubernetes.io/master"
}

variable "empty_string" {
  default = " "
}

# Controller Container Linux Config
data "template_file" "controller_config" {
  count = "${var.controller_count}"

  template = "${file("${path.module}/cl/controller.yaml.tmpl")}"

  vars = {
    kubeconfig            = "${indent(10, module.bootkube.kubeconfig)}"
    master                = "${count.index == 0 ? var.master_label : var.empty_string }"
    key_name              = "${var.ssh_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "repeat" {
  count = "${var.controller_count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}

data "ct_config" "controller_ign" {
  count        = "${var.controller_count}"
  content      = "${element(data.template_file.controller_config.*.rendered, count.index)}"
  pretty_print = false

  # snippets     = ["${var.controller_clc_snippets}"]
}
