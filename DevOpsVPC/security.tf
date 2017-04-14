#
# Project Name:: en_infra_aws
# File:: security.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Security related items such as: keys, SecGroups, ACL, etc.
#

#-- SSH Key used to connect to our instances
resource "aws_key_pair" "xanto" {
  key_name = "${var.ssh_public_key_name}"
  public_key = "${file(var.ssh_public_key_file)}"
}

#-- Security Groups
resource "aws_security_group" "AllowICMP" {
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "Allow all ICMP traffic"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_SG_%s", var.vpc_name, "AllowICMP")))}"
}

#--
resource "aws_security_group" "DefaultPub" {
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "Default VPC security group for public facing IPs"

  # TCP access
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["194.126.146.0/24"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound acces to anywhere
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_SG_%s", var.vpc_name, "DefaultPub")))}"
}

#--
resource "aws_security_group" "DefaultPrv" {
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "Default VPC security group for private IPs"

  # Permit access from the VMs that resides in Public Subnet
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.DefaultPub.id}"]
  }

  # Outbound acces to anywhere
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_SG_%s", var.vpc_name, "DefaultPrv")))}"
}
