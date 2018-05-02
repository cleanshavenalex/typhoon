# Network Load Balancer for Ingress
resource "aws_elb" "ingress" {
  name     = "${var.name}-ingress"
  internal = true

  subnets = ["${var.worker_subnets}"]

  cross_zone_load_balancing = true

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
}

resource "aws_route53_record" "ingress" {
  zone_id = "${var.dns_zone_id}"

  name = "${format("ingress-%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_elb.ingress.dns_name}"
    zone_id                = "${aws_elb.ingress.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_autoscaling_attachment" "ingress" {
  autoscaling_group_name = "${aws_autoscaling_group.workers.id}"
  elb                    = "${aws_elb.ingress.id}"
}

# # Network Load Balancer for Ingress
# resource "aws_lb" "ingress" {
#   name               = "${var.name}-ingress"
#   load_balancer_type = "network"
#   internal           = true


#   subnets = ["${var.worker_subnets}"]


#   enable_cross_zone_load_balancing = true
# }


# # Forward HTTP traffic to workers
# resource "aws_lb_listener" "ingress-http" {
#   load_balancer_arn = "${aws_lb.ingress.arn}"
#   protocol          = "TCP"
#   port              = 80


#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.workers-http.arn}"
#   }
# }


# # Forward HTTPS traffic to workers
# resource "aws_lb_listener" "ingress-https" {
#   load_balancer_arn = "${aws_lb.ingress.arn}"
#   protocol          = "TCP"
#   port              = 443


#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.workers-https.arn}"
#   }
# }


# # Network Load Balancer target groups of instances


# resource "aws_lb_target_group" "workers-http" {
#   name        = "${var.name}-workers-http"
#   vpc_id      = "${var.vpc_id}"
#   target_type = "instance"


#   protocol = "TCP"
#   port     = 80


#   # Ingress Controller HTTP health check
#   health_check {
#     protocol = "HTTP"
#     port     = 10254
#     path     = "/healthz"


#     # NLBs required to use same healthy and unhealthy thresholds
#     healthy_threshold   = 3
#     unhealthy_threshold = 3


#     # Interval between health checks required to be 10 or 30
#     interval = 10
#   }
# }


# resource "aws_lb_target_group" "workers-https" {
#   name        = "${var.name}-workers-https"
#   vpc_id      = "${var.vpc_id}"
#   target_type = "instance"


#   protocol = "TCP"
#   port     = 443


#   # Ingress Controller HTTP health check
#   health_check {
#     protocol = "HTTP"
#     port     = 10254
#     path     = "/healthz"


#     # NLBs required to use same healthy and unhealthy thresholds
#     healthy_threshold   = 3
#     unhealthy_threshold = 3


#     # Interval between health checks required to be 10 or 30
#     interval = 10
#   }
# }

