#
# Project Name:: en_infra_aws
# File:: main.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Provisioning for our private Datacenter with Networking.
#

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = "${var.enable_dns_support}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  lifecycle { 
    create_before_destroy = true
  }
  tags = "${merge(var.default_tags, map("Name", var.vpc_name))}"
}

#-- IGW for Public Subnet
resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PubGW_%s", var.vpc_name, element(var.aws_azs, count.index))))}"
}

################# PUBLIC SUBNET
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.vpc_public_subnets, count.index)}"
  availability_zone = "${element(var.aws_azs, count.index)}"
  count             = "${length(var.vpc_public_subnets)}"

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PubSubnet_%s", var.vpc_name, element(var.aws_azs, count.index))))}"

  lifecycle { create_before_destroy = true }

}

#--
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags = "${merge(var.default_tags, map("VPC", var.vpc_name), map("Name", format("%s_PubSubRT_%s", var.vpc_name, element(var.aws_azs, count.index))))}"
}

#--
resource "aws_route_table_association" "public" {
  count          = "${length(var.vpc_public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
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

#--
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

#--
resource "aws_route_table_association" "private" {
  count          = "${length(var.vpc_private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  lifecycle { create_before_destroy = true }
}

