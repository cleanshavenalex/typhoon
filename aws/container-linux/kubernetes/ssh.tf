# Secure copy etcd TLS assets to controllers.
resource "null_resource" "copy-controller-secrets" {
  connection {
    type    = "ssh"
    host    = "${element(aws_instance.bastion.*.public_ip, 0)}"
    user    = "ubuntu"
    timeout = "15m"
  }

  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.controllers.*.id)}"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_ca_cert}"
    destination = "$HOME/etcd-client-ca.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_client_cert}"
    destination = "$HOME/etcd-client.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_client_key}"
    destination = "$HOME/etcd-client.key"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_server_cert}"
    destination = "$HOME/etcd-server.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_server_key}"
    destination = "$HOME/etcd-server.key"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_peer_cert}"
    destination = "$HOME/etcd-peer.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_peer_key}"
    destination = "$HOME/etcd-peer.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ssl/etcd/etcd",
      "sudo mv etcd-client* /etc/ssl/etcd/",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/server-ca.crt",
      "sudo mv etcd-server.crt /etc/ssl/etcd/etcd/server.crt",
      "sudo mv etcd-server.key /etc/ssl/etcd/etcd/server.key",
      "sudo cp /etc/ssl/etcd/etcd-client-ca.crt /etc/ssl/etcd/etcd/peer-ca.crt",
      "sudo mv etcd-peer.crt /etc/ssl/etcd/etcd/peer.crt",
      "sudo mv etcd-peer.key /etc/ssl/etcd/etcd/peer.key",
      "sudo chown -R etcd:etcd /etc/ssl/etcd",
      "sudo chmod -R 500 /etc/ssl/etcd",
    ]
  }
}

# Secure copy bootkube assets to the bastion and start bootkube to perform
# one-time self-hosted cluster bootstrapping.
resource "null_resource" "bootkube-start" {
  depends_on = [
    "module.bastion",
    "module.bootkube",
    "module.workers",
    "aws_route53_record.apiserver",
    "null_resource.copy-controller-secrets",
  ]

  connection {
    type    = "ssh"
    host    = "${aws_instance.bastion.0.public_ip}"
    user    = "ubuntu"
    timeout = "5m"
  }

  provisioner "file" {
    source      = "${var.asset_dir}"
    destination = "$HOME/assets"
  }

  provisioner "file" {
    source      = "./${var.ssh_key}"
    destination = "$HOME/${var.ssh_key}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      #"sudo mv $HOME/assets /opt/bootkube",
      "sudo scp -i ${var.ssh_key}.pem $HOME/assets core@${aws_instance.controllers.0.private_ip}:/opt/assets",

      "ssh -i ${var.ssh_key}.pem -t core@${aws_instance.controllers.0.private_ip} sudo systemctl start bootkube",
    ]

    #"sudo systemctl start bootkube",
  }
}
