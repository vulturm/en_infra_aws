#
# Project Name:: en_aws_infra
# File:: main.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Module import definitions with variables overrides.


provider "aws" {
  region                    = "${var.aws_region}"
  #-- must be fullpath, ~ is not evaluated
  shared_credentials_file   = "/home/vagrant/.aws/credentials"
}

resource "aws_key_pair" "xanto" {
  key_name = "${var.ssh_key_name}"
  public_key = "${var.ssh_public_key}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  lifecycle { 
    create_before_destroy = true
  }
  tags = "${merge(var.default_tags, map("Name", var.vpc_name))}"
}

################# PUBLIC SUBNET

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PubGW_%s", var.vpc_name, element(var.aws_azs, count.index))))}"
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.vpc_public_subnets, count.index)}"
  availability_zone = "${element(var.aws_azs, count.index)}"
  count             = "${length(var.vpc_public_subnets)}"

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PubSubnet_%s", var.vpc_name, element(var.aws_azs, count.index))))}"

  lifecycle { create_before_destroy = true }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PubSubRT_%s", var.vpc_name, element(var.aws_azs, count.index))))}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.vpc_public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}


################## NAT INSTANCE

resource "aws_instance" "NatInstance" {
  ami                         = "${var.ec2_ami}"
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
  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -C POSTROUTING -o eth0 -s ${join(",", var.vpc_private_subnets)} -j MASQUERADE 2> /dev/null || sudo iptables -t nat -A POSTROUTING -o eth0 -s ${join(",", var.vpc_private_subnets)} -j MASQUERADE",
      "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth0.send_redirects=0' >> /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=131072' >> /etc/sysctl.conf"
    ]
    connection {
      user     = "centos"
      agent    = true
    }
  }
  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_%s", var.vpc_name, "NATInstance")))}"
}

################ PRIVATE SUBNET

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.vpc_private_subnets, count.index)}"
  availability_zone = "${element(var.aws_azs, count.index)}"
  count             = "${length(var.vpc_private_subnets)}"

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PrvSubnet_%s", var.vpc_name, element(var.aws_azs, count.index))))}"
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  count  = "${length(var.vpc_private_subnets)}"

  route {
    cidr_block     = "0.0.0.0/0"
    instance_id    = "${aws_instance.NatInstance.id}"
#    nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
  }

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PrvSubRT_%s", var.vpc_name, element(var.aws_azs, count.index))))}"
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.vpc_private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  lifecycle { create_before_destroy = true }
}


# Security Group #
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

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_SG_%s", var.vpc_name, "Default")))}"
}


############################
resource "aws_instance" "TestInstance" {
  ami                         = "${var.ec2_ami}"
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


