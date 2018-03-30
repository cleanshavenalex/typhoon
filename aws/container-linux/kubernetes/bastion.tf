# Bastion instance
resource "aws_instance" "bastion" {
  count = 1

  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  instance_type = "t2.medium"
  key_name      = "${var.ssh_key}"
  ami           = "ami-4e79ed36"

  #user_data = "${element(data.ct_config.controller_ign.*.rendered, count.index)}"

  # storage
  root_block_device {
    volume_type = "standard"
    volume_size = "${var.disk_size}"
  }
  # network
  associate_public_ip_address = true
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.controller.id}"]
  lifecycle {
    ignore_changes = ["ami"]
  }
}
