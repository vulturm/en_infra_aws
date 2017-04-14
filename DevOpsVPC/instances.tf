#
# Project Name:: en_infra_aws
# File:: instances.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Provisions AWS instances used in our project
#

################## NAT INSTANCE
resource "aws_instance" "NatInstance" {
  ami                         = "${replace(var.ec2_custom_image, "/^ami-.*/", "1") == 1 ? var.ec2_custom_image : data.aws_ami.centos.image_id}"
  availability_zone           = "${var.aws_azs[0]}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.xanto.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.AllowICMP.id}", "${aws_security_group.DefaultPub.id}"]
  subnet_id                   = "${element(aws_subnet.public.*.id, count.index)}"

  source_dest_check           = false

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }
  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_%s", var.vpc_name, "NATInstance")))}"
}

resource "aws_eip" "NatInstance" {
    instance = "${aws_instance.NatInstance.id}"
    vpc      = true
}

#-- workarround adding a triggered resource
#-- because of a circular dependency between
#-- eip and aws_instance
resource "null_resource" "preparation" {
  triggers {
    instance = "${aws_instance.NatInstance.id}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -C POSTROUTING -o eth0 -s ${join(",", var.vpc_private_subnets)} -j MASQUERADE 2> /dev/null || sudo iptables -t nat -A POSTROUTING -o eth0 -s ${join(",", var.vpc_private_subnets)} -j MASQUERADE",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth0.send_redirects=0' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=131072' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p"
    ]
    connection {
      host        = "${aws_eip.NatInstance.public_ip}"
      user        = "centos"
      timeout     = "30s"
      private_key = "${file("/home/vagrant/.ssh/id_rsa")}"
    }
  }
}

################## TEST INSTANCE
resource "aws_instance" "TestInstance" {
  ami                         = "${replace(var.ec2_custom_image, "/^ami-.*/", "1") == 1 ? var.ec2_custom_image : data.aws_ami.centos.image_id}"
  availability_zone           = "${var.aws_azs[0]}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.xanto.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.AllowICMP.id}", "${aws_security_group.DefaultPrv.id}"]
  subnet_id                   = "${element(aws_subnet.private.*.id, count.index)}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }
  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_%s", var.vpc_name, "TestInstance")))}"
}
