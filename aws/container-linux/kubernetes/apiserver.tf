# kube-apiserver Network Load Balancer DNS Record
resource "aws_route53_record" "apiserver" {
  zone_id = "${var.dns_zone_id}"

  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_elb.apiserver.dns_name}"
    zone_id                = "${aws_elb.apiserver.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apiserver-public" {
  zone_id = "${var.public_zone_id}"

  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_elb.apiserver.dns_name}"
    zone_id                = "${aws_elb.apiserver.zone_id}"
    evaluate_target_health = true
  }
}

# ELB
resource "aws_elb" "apiserver" {
  name     = "${var.cluster_name}-apiserver"
  internal = true

  # count              = "${var.controller_count}"
  security_groups = ["${aws_security_group.controller.id}"]
  subnets         = ["${var.master_subnets}", "${var.master_subnets[1]}"]

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"

    #ssl_certificate_id = "${var.elb_ssl_certificate_id}"
  }

  instances                 = ["${aws_instance.controllers.*.id}"]
  cross_zone_load_balancing = true
}
