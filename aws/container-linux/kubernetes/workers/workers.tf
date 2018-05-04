# Workers AutoScaling Group
resource "aws_autoscaling_group" "workers" {
  name = "${var.name}-worker ${aws_launch_configuration.worker.name}"

  # count
  desired_capacity          = "${var.count}"
  min_size                  = "${var.count}"
  max_size                  = "${var.count + 2}"
  default_cooldown          = 30
  health_check_grace_period = 30

  # network
  vpc_zone_identifier = ["${var.worker_subnets}"]

  # template
  launch_configuration = "${aws_launch_configuration.worker.name}"

  # # target groups to which instances should be added
  # target_group_arns = [
  #   "${aws_lb_target_group.workers-http.id}",
  #   "${aws_lb_target_group.workers-https.id}",
  # ]

  lifecycle {
    # override the default destroy and replace update behavior
    create_before_destroy = true
  }
  tags = [{
    key                 = "Name"
    value               = "${var.name}-worker"
    propagate_at_launch = true
  }]
}

# Worker template
resource "aws_launch_configuration" "worker" {
  image_id      = "${data.aws_ami.coreos.image_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key}"

  user_data = "${data.ct_config.worker_ign.rendered}"

  # storage
  root_block_device {
    volume_type = "io1"
    iops        = "1000"
    volume_size = "100"
  }

  # network
  security_groups = ["${var.security_groups}"]

  lifecycle {
    // Override the default destroy and replace update behavior
    create_before_destroy = true
    ignore_changes        = ["image_id"]
  }
}

# Worker Container Linux Config
data "template_file" "worker_config" {
  template = "${file("${path.module}/cl/worker.yaml.tmpl")}"

  vars = {
    vpc_id     = "${var.vpc_id}"
    kubeconfig = "${indent(10, var.kubeconfig)}"

    #ssh_key               = "${var.ssh_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "ct_config" "worker_ign" {
  content      = "${data.template_file.worker_config.rendered}"
  pretty_print = false

  #snippets     = ["${var.clc_snippets}"]
}
