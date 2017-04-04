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
  tags      {
    Name = "${var.vpc_name}"
  }
}

#--
module "public_subnet" {
  source = "github.com/hashicorp/best-practices//terraform/modules/aws/network/public_subnet"
  vpc_id = "${aws_vpc.vpc.id}"
  azs    = "${join(",",var.aws_azs)}"
  #--
  name   = "${var.vpc_name}_Public_Subnet"
  cidrs  = "${join(",", var.vpc_public_subnets)}"
}

resource "aws_instance" "NatInstance" {
  ami                         = "${var.ec2_ami}"
  availability_zone           = "${var.aws_azs[0]}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.xanto.key_name}"
  security_groups             = ["${aws_security_group.Allow_ICMP.id}", "${aws_security_group.sg_test.id}"]
  subnet_id                   = "${module.public_subnet.subnet_ids}"
  associate_public_ip_address = true
  source_dest_check           = false
  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s-%s", var.vpc_name, "NAT_Instance")))}"
}


module "private_subnet" {
  source = "github.com/hashicorp/best-practices//terraform/modules/aws/network/private_subnet"
  vpc_id = "${aws_vpc.vpc.id}"
  azs    = "${join(",",var.aws_azs)}"

  name   = "${var.vpc_name}_Private_Subnet"
  cidrs  = "${join(",", var.vpc_private_subnets)}"
#  nat_gateway_ids = "${module.NatInstance.id}"
  nat_gateway_ids = "${aws_instance.NatInstance.id}"
}



# Security Group #
resource "aws_security_group" "Allow_ICMP" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "Allow_ICMP"
  description = "Allow all ICMP traffic"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.vpc_name}-Allow_ICMP"
  }
}

resource "aws_security_group" "sg_test" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name = "sg_test"
  description = "default VPC security group"

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
  tags {
    Name = "${var.vpc_name}-SG_Test"
  }
}
