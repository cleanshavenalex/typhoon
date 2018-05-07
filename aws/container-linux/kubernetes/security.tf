# Security Groups (instance firewalls)

# Controller security group

resource "aws_security_group_rule" "vpn-ssh-to-controllers" {
  security_group_id = "${aws_security_group.controller.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "vpn-ssh-to-etcd" {
  security_group_id = "${aws_security_group.etcd.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "vpn-443-to-controllers" {
  security_group_id        = "${aws_security_group.controller.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = "${var.vpn_security_group}"
}

resource "aws_security_group_rule" "vpn-ssh-to-workers" {
  security_group_id        = "${aws_security_group.worker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${var.vpn_security_group}"
}

resource "aws_security_group_rule" "vpn-443-to-workers" {
  security_group_id        = "${aws_security_group.worker.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = "${var.vpn_security_group}"
}

resource "aws_security_group" "controller" {
  name        = "${var.cluster_name}-controller"
  description = "${var.cluster_name} controller security group"

  vpc_id = "${var.vpc_id}"

  tags = "${map("Name", "${var.cluster_name}-controller")}"
}

resource "aws_security_group_rule" "controller-icmp" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "icmp"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}

# resource "aws_security_group_rule" "controller-ssh" {
#   security_group_id = "${aws_security_group.controller.id}"

#   type        = "ingress"
#   protocol    = "tcp"
#   from_port   = 22
#   to_port     = 22
#   cidr_blocks = ["0.0.0.0/0"]
# }

resource "aws_security_group_rule" "controller-apiserver" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "controller-etcd" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "controller-flannel" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8472
  to_port                  = 8472
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-flannel-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "udp"
  from_port = 8472
  to_port   = 8472
  self      = true
}

resource "aws_security_group_rule" "controller-node-exporter" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9100
  to_port                  = 9100
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-kubelet-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "controller-kubelet-cidr" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 10250
  to_port     = 10250
  cidr_blocks = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "controller-kubelet-cidr-1" {
  security_group_id = "${aws_security_group.controller.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 10251
  to_port     = 10251
  cidr_blocks = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "controller-kubelet-self-2" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10251
  to_port   = 10251
  self      = true
}

resource "aws_security_group_rule" "controller-kubelet-read" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10255
  to_port                  = 10255
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-kubelet-read-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
  self      = true
}

resource "aws_security_group_rule" "controller-bgp" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 179
  to_port                  = 179
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-bgp-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 179
  to_port   = 179
  self      = true
}

resource "aws_security_group_rule" "controller-ipip" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = 4
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-ipip-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = 4
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-ipip-legacy" {
  security_group_id = "${aws_security_group.controller.id}"

  type                     = "ingress"
  protocol                 = 94
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "controller-ipip-legacy-self" {
  security_group_id = "${aws_security_group.controller.id}"

  type      = "ingress"
  protocol  = 94
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "controller-egress" {
  security_group_id = "${aws_security_group.controller.id}"

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group" "etcd" {
  count  = 1
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  # ingress {
  #   protocol  = "tcp"
  #   from_port = 22
  #   to_port   = 22


  #   cidr_blocks = ["${var.host_cidr}"]
  # }

  ingress {
    protocol  = "tcp"
    from_port = 2379
    to_port   = 2380

    cidr_blocks = ["${var.host_cidr}"]
  }
  ingress {
    protocol  = "tcp"
    from_port = 2380
    to_port   = 2380
    self      = true
  }
  ingress {
    protocol  = "tcp"
    from_port = 2379
    to_port   = 2380
    self      = true
  }
}

resource "aws_security_group_rule" "etcd-ssh" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = "${var.vpn_security_group}"
  security_group_id        = "${aws_security_group.etcd.id}"
}

resource "aws_security_group_rule" "etcd-2379" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2379
  to_port                  = 2379
  source_security_group_id = "${aws_security_group.controller.id}"
  security_group_id        = "${aws_security_group.etcd.id}"
}

resource "aws_security_group_rule" "etcd-worker-2379" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2379
  to_port                  = 2379
  source_security_group_id = "${aws_security_group.worker.id}"
  security_group_id        = "${aws_security_group.etcd.id}"
}

# Bastion security group
resource "aws_security_group" "bastion" {
  name        = "${var.cluster_name}-bastion"
  description = "${var.cluster_name} bastion security group"

  vpc_id = "${var.vpc_id}"

  tags = "${map("Name", "${var.cluster_name}-bastion")}"
}

resource "aws_security_group_rule" "bastion-ssh" {
  security_group_id = "${aws_security_group.bastion.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion-egress" {
  security_group_id = "${aws_security_group.bastion.id}"

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

# Worker security group

resource "aws_security_group" "worker" {
  name        = "${var.cluster_name}-worker"
  description = "${var.cluster_name} worker security group"

  vpc_id = "${var.vpc_id}"

  tags = "${map("Name", "${var.cluster_name}-worker")}"
}

resource "aws_security_group_rule" "worker-icmp" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "icmp"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-ssh" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "worker-http" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "worker-https" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-flannel" {
  security_group_id = "${aws_security_group.worker.id}"

  type                     = "ingress"
  protocol                 = "udp"
  from_port                = 8472
  to_port                  = 8472
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "worker-flannel-self" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = "udp"
  from_port = 8472
  to_port   = 8472
  self      = true
}

resource "aws_security_group_rule" "worker-node-exporter" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 9100
  to_port   = 9100
  self      = true
}

resource "aws_security_group_rule" "ingress-health" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 10254
  to_port     = 10254
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "worker-kubelet" {
  security_group_id = "${aws_security_group.worker.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10250
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "worker-kubelet-cidr" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 10250
  to_port     = 10250
  cidr_blocks = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "worker-kubelet-1-cidr" {
  security_group_id = "${aws_security_group.worker.id}"

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 10251
  to_port     = 10251
  cidr_blocks = ["${var.host_cidr}"]
}

resource "aws_security_group_rule" "worker-kubelet-self" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "worker-kubelet-read" {
  security_group_id = "${aws_security_group.worker.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 10255
  to_port                  = 10255
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "worker-kubelet-read-self" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 10255
  to_port   = 10255
  self      = true
}

resource "aws_security_group_rule" "worker-bgp" {
  security_group_id = "${aws_security_group.worker.id}"

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 179
  to_port                  = 179
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "worker-bgp-self" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = "tcp"
  from_port = 179
  to_port   = 179
  self      = true
}

resource "aws_security_group_rule" "worker-ipip" {
  security_group_id = "${aws_security_group.worker.id}"

  type                     = "ingress"
  protocol                 = 4
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "worker-ipip-self" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = 4
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "worker-ipip-legacy" {
  security_group_id = "${aws_security_group.worker.id}"

  type                     = "ingress"
  protocol                 = 94
  from_port                = 0
  to_port                  = 0
  source_security_group_id = "${aws_security_group.controller.id}"
}

resource "aws_security_group_rule" "worker-ipip-legacy-self" {
  security_group_id = "${aws_security_group.worker.id}"

  type      = "ingress"
  protocol  = 94
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "worker-egress" {
  security_group_id = "${aws_security_group.worker.id}"

  type             = "egress"
  protocol         = "-1"
  from_port        = 0
  to_port          = 0
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
