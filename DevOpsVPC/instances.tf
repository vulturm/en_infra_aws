#
# Project Name:: en_infra_aws
# File:: instances.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Provisions AWS instances used in our project
#

################## NAT INSTANCE
module "nat" {
  source                = "../modules/nat"

  number_of_instances   = 1

  instance_name         = "NatVPN"
  vpc_name              = "${var.vpc_name}"
  vpc_id                = "${aws_vpc.vpc.id}"
  instance_type         = "t2.micro"
  #-- we always want latest CentOS 7 AMI for NAT
  ami_id                = "${data.aws_ami.centos.image_id}"
  subnet_id             = "${join(",", aws_subnet.public.*.id)}"
  private_subnets_cidr  = "${join(",", aws_subnet.private.*.cidr_block)}"
  inbound_ports         = "${var.nat_inbound_ports}"
  user_data             = "../files/user-data/nat-vpn.cfg"
  key_name              = "${aws_key_pair.xanto.key_name}"
  #-- assuming 'private key name' by removing the '.pub' extension
  private_key_file      = "${replace(var.ssh_public_key_file, ".pub", "")}"
  sgs                   = "${aws_default_security_group.default.id},${aws_security_group.AllowICMP.id},${aws_security_group.DefaultPub.id}"
}

################### TEST INSTANCE
resource "aws_instance" "TestInstance" {
  ami                         = "${replace(var.ec2_custom_image, "/^ami-.*/", "1") == 1 ? var.ec2_custom_image : data.aws_ami.centos.image_id}"
  availability_zone           = "${var.aws_azs[0]}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.xanto.key_name}"
  vpc_security_group_ids      = ["${aws_default_security_group.default.id}", "${aws_security_group.AllowICMP.id}", "${aws_security_group.DefaultPrv.id}"]
  subnet_id                   = "${element(aws_subnet.private.*.id, count.index)}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }
  tags = "${merge(var.default_tags, map("ManageRunningTime", "WorkingHoursStop"), map("VPC", var.vpc_name), map("Name", format("%s_%s", var.vpc_name, "TestInstance")))}"
}
