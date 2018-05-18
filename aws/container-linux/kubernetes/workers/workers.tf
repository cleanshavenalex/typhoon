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
  image_id             = "${data.aws_ami.coreos.image_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.ssh_key}"
  iam_instance_profile = "${aws_iam_instance_profile.worker_profile.name}"
  user_data            = "${data.ct_config.worker_ign.rendered}"

  # storage
  root_block_device {
    volume_type = "io1"
    iops        = "3000"
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
    pod_cidr   = "${var.pod_cidr}"

    #ssh_key               = "${var.ssh_key}"
    k8s_dns_service_ip    = "${cidrhost(var.service_cidr, 10)}"
    cluster_domain_suffix = "${var.cluster_domain_suffix}"
  }
}

data "ct_config" "worker_ign" {
  content      = "${data.template_file.worker_config.rendered}"
  pretty_print = false

  ### TODO add command to set ec2 source dest check to false for Calico networking?
  #snippets     = ["${var.clc_snippets}"]
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.cluster_name}-worker-profile"

  role = "${aws_iam_role.worker_role.name}"

  provisioner "local-exec" {
    command = "sleep 125"
    command = "echo ${aws_iam_instance_profile.worker_profile.arn}"
  }
}

data "aws_iam_role" "worker_role" {
  #count     = "${var.worker_iam_role == "" ? 0 : 1}"
  name = "${aws_iam_role.worker_role.name}"
}

resource "aws_iam_role" "worker_role" {
  #count = "${var.worker_iam_role == "" ? 1 : 0}"
  name = "${var.cluster_name}-worker-role"
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

resource "aws_iam_role_policy" "worker_policy" {
  #count = "${var.worker_iam_role == "" ? 1 : 0}"
  name = "${var.cluster_name}_worker_policy"
  role = "${aws_iam_role.worker_role.id}"

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
        "s3:GetObject"
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
