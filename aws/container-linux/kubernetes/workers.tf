module "workers" {
  source = "workers"
  name   = "${var.cluster_name}"

  # AWS
  vpc_id          = "${var.vpc_id}"
  cluster_name    = "${var.cluster_name}"
  dns_zone        = "${var.dns_zone}"
  dns_zone_id     = "${var.dns_zone_id}"
  public_zone_id  = "${var.public_zone_id}"
  public_subnets  = ["${var.public_subnets}"]
  subnet_ids      = ["${var.worker_subnets}"]
  worker_subnets  = ["${var.worker_subnets}"]
  security_groups = ["${aws_security_group.worker.id}"]
  count           = "${var.worker_count}"

  instance_type = "${var.worker_type}"
  os_channel    = "${var.os_channel}"
  disk_size     = "${var.disk_size}"

  # configuration
  kubeconfig            = "${module.bootkube.kubeconfig}"
  ssh_key               = "${var.ssh_key}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  clc_snippets          = "${var.worker_clc_snippets}"
}

# resource "aws_iam_instance_profile" "worker_profile" {
#   name = "${var.cluster_name}-worker-profile"


#   role = "${var.worker_iam_role == "" ?
#     join("|", aws_iam_role.worker_role.*.name) :
#     join("|", data.aws_iam_role.worker_role.*.name)
#   }"
# }


# data "aws_iam_role" "worker_role" {
#   count = "${var.worker_iam_role == "" ? 0 : 1}"
#   name  = "${var.worker_iam_role}"
# }


# resource "aws_iam_role" "worker_role" {
#   count = "${var.worker_iam_role == "" ? 1 : 0}"
#   name  = "${var.cluster_name}-worker-role"
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


# resource "aws_iam_role_policy" "worker_policy" {
#   count = "${var.worker_iam_role == "" ? 1 : 0}"
#   name  = "${var.cluster_name}_worker_policy"
#   role  = "${aws_iam_role.worker_role.id}"


#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "ec2:Describe*",
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "ec2:AttachVolume",
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "ec2:DetachVolume",
#       "Resource": "*"
#     },
#     {
#       "Action": "elasticloadbalancing:*",
#       "Resource": "*",
#       "Effect": "Allow"
#     },
#     {
#       "Action" : [
#         "s3:GetObject"
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

