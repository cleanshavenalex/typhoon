# Discrete DNS records for each controller's private IPv4 for etcd usage
resource "aws_route53_record" "etcd_srv_discover" {
  count   = "1"
  name    = "_etcd-server-ssl._tcp"
  type    = "SRV"
  zone_id = "${var.dns_zone_id}"
  records = ["${formatlist("0 0 2380 %s", aws_route53_record.etc_a_nodes.*.fqdn)}"]
  ttl     = "300"
}

resource "aws_route53_record" "etcd_srv_client" {
  count   = "1"
  name    = "_etcd-client-ssl._tcp"
  type    = "SRV"
  zone_id = "${var.dns_zone_id}"
  records = ["${formatlist("0 0 2379 %s", aws_route53_record.etc_a_nodes.*.fqdn)}"]
  ttl     = "60"
}

resource "aws_route53_record" "etc_a_nodes" {
  count = "${var.etcd_count}"

  # DNS Zone where record should be created
  zone_id = "${var.dns_zone_id}"

  name = "${format("%s-etcd%d.%s.", var.cluster_name, count.index, var.dns_zone)}"
  type = "A"
  ttl  = 60

  # private IPv4 address for etcd
  records = ["${element(aws_instance.etcd_node.*.private_ip, count.index)}"]
}

# Controller instances
resource "aws_instance" "etcd_node" {
  count = "${var.etcd_count}"

  tags = {
    Name = "${var.cluster_name}-etcd-${count.index}"
  }

  instance_type = "${var.etcd_type}"
  key_name      = "${var.ssh_key}"
  ami           = "${data.aws_ami.coreos.image_id}"
  user_data     = "${element(data.ct_config.etcd_ign.*.rendered, count.index)}"

  # storage
  root_block_device {
    volume_type = "io1"
    iops        = 1000
    volume_size = 100
  }

  # network
  associate_public_ip_address = false

  subnet_id              = "${element(var.worker_subnets, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.etcd.id}"]

  lifecycle {
    ignore_changes = ["ami"]
  }
}

# Controller Container Linux Config
data "template_file" "etcd_config" {
  count = "${var.etcd_count}"

  template = "${file("${path.module}/etcd/etcd.yaml.tmpl")}"

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name   = "etcd${count.index}"
    etcd_domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"

    # etcd0=https://cluster-etcd0.example.com,etcd1=https://cluster-etcd1.example.com,...
    etcd_initial_cluster = "${join(",", formatlist("%s=https://%s:2380", null_resource.etcd_repeat.*.triggers.name, null_resource.etcd_repeat.*.triggers.domain))}"

    kubeconfig = "${indent(10, module.bootkube.kubeconfig)}"

    key_name              = "${var.ssh_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

# Horrible hack to generate a Terraform list of a desired length without dependencies.
# Ideal ${repeat("etcd", 3) -> ["etcd", "etcd", "etcd"]}
resource null_resource "etcd_repeat" {
  count = "${var.etcd_count}"

  triggers {
    name   = "etcd${count.index}"
    domain = "${var.cluster_name}-etcd${count.index}.${var.dns_zone}"
  }
}

data "ct_config" "etcd_ign" {
  count        = "${var.etcd_count}"
  content      = "${element(data.template_file.etcd_config.*.rendered, count.index)}"
  pretty_print = false

  # snippets     = ["${var.controller_clc_snippets}"]
}
