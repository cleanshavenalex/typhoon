module "bastions" {
  source         = "bastions"
  name           = "bastions"
  vpc_id         = "${var.vpc_id}"
  cluster_name   = "${var.cluster_name}"
  public_subnets = "${aws_subnet.public.*.id}"

  security_groups = ["${aws_security_group.bastion.id}"]

  #user_data = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"

  instance_type = "t2.medium"
  ssh_key       = "${var.ssh_key}"
}
