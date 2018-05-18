# Controller instances
resource "aws_instance" "controllers" {
  count = "${var.controller_count}"

  tags = {
    Name = "${var.cluster_name}-controller-${count.index}"
  }

  instance_type        = "${var.controller_type}"
  key_name             = "${var.ssh_key}"
  ami                  = "${data.aws_ami.coreos.image_id}"
  user_data            = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"
  iam_instance_profile = "${aws_iam_instance_profile.master_profile.name}"

  # storage
  root_block_device {
    volume_type = "io1"
    iops        = "3000"
    volume_size = "100"
  }

  # network
  associate_public_ip_address = false
  source_dest_check           = false
  subnet_id                   = "${var.master_subnets[count.index]}"
  vpc_security_group_ids      = ["${aws_security_group.controller.id}"]

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
    pod_cidr              = "${var.pod_cidr}"
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

resource "aws_iam_instance_profile" "master_profile" {
  name = "${var.cluster_name}-master-profile"
  role = "${data.aws_iam_role.master_role.name}"

  provisioner "local-exec" {
    command = "sleep 125"
    command = "echo ${aws_iam_instance_profile.master_profile.arn}"
  }
}

data "aws_iam_role" "master_role" {
  #count     = "${var.master_iam_role == "" ? 0 : 1}"
  name = "${aws_iam_role.master_role.name}"
}

resource "aws_iam_role" "master_role" {
  #count = "${var.master_iam_role == "" ? 1 : 0}"
  name = "${var.cluster_name}-master-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "master_policy" {
  #count = "${var.master_iam_role == "" ? 1 : 0}"
  name = "${var.cluster_name}_master_policy"
  role = "${aws_iam_role.master_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": "elasticloadbalancing:*",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "s3:GetObject",
        "s3:HeadObject",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
