# kube-apiserver Network Load Balancer DNS Record
resource "aws_route53_record" "apiserver" {
  zone_id = "${var.dns_zone_id}"

  name = "${format("%s.%s.", var.cluster_name, var.dns_zone)}"
  type = "A"

  # AWS recommends their special "alias" records for ELBs
  alias {
    name                   = "${aws_lb.apiserver.dns_name}"
    zone_id                = "${aws_lb.apiserver.zone_id}"
    evaluate_target_health = true
  }
}

# Network Load Balancer for apiservers
resource "aws_lb" "apiserver" {
  name               = "${var.cluster_name}-apiserver"
  load_balancer_type = "network"
  internal           = true

  subnets = ["${var.master_subnets}"]

  enable_cross_zone_load_balancing = true
}

# Forward HTTP traffic to controllers
resource "aws_lb_listener" "apiserver-https" {
  load_balancer_arn = "${aws_lb.apiserver.arn}"
  protocol          = "TCP"
  port              = "443"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.controllers.arn}"
  }
}

# Target group of controllers
resource "aws_lb_target_group" "controllers" {
  name        = "${var.cluster_name}-controllers"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  protocol = "TCP"
  port     = 443

  # Kubelet HTTP health check
  health_check {
    protocol = "TCP"
    port     = 443

    # NLBs required to use same healthy and unhealthy thresholds
    healthy_threshold   = 3
    unhealthy_threshold = 3

    # Interval between health checks required to be 10 or 30
    interval = 10
  }
}

# Attach controller instances to apiserver NLB
resource "aws_lb_target_group_attachment" "controllers" {
  count = "${var.controller_count}"

  target_group_arn = "${aws_lb_target_group.controllers.arn}"
  target_id        = "${element(aws_instance.controllers.*.id, count.index)}"
  port             = 443
}

# resource "aws_iam_instance_profile" "master_profile" {
#   name = "${var.cluster_name}-master-profile"


#   role = "${var.master_iam_role == "" ?
#     join("|", aws_iam_role.master_role.*.name) :
#     join("|", data.aws_iam_role.master_role.*.name)
#   }"
# }


# data "aws_iam_role" "master_role" {
#   count = "${var.master_iam_role == "" ? 0 : 1}"
#   name  = "${var.master_iam_role}"
# }


# resource "aws_iam_role" "master_role" {
#   count = "${var.master_iam_role == "" ? 1 : 0}"
#   name  = "${var.cluster_name}-master-role"
#   path  = "/"


#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }


# resource "aws_iam_role_policy" "master_policy" {
#   count = "${var.master_iam_role == "" ? 1 : 0}"
#   name  = "${var.cluster_name}_master_policy"
#   role  = "${aws_iam_role.master_role.id}"


#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "ec2:*",
#       "Resource": "*",
#       "Effect": "Allow"
#     },
#     {
#       "Action": "elasticloadbalancing:*",
#       "Resource": "*",
#       "Effect": "Allow"
#     },
#     {
#       "Action" : [
#         "s3:GetObject",
#         "s3:HeadObject",
#         "s3:ListBucket",
#         "s3:PutObject"
#       ],
#       "Resource": "arn:${local.arn}:s3:::*",
#       "Effect": "Allow"
#     },
#     {
#       "Action" : [
#         "autoscaling:DescribeAutoScalingGroups",
#         "autoscaling:DescribeAutoScalingInstances"
#       ],
#       "Resource": "*",
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }

