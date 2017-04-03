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

# Network
module "vpc" {
  source                = "github.com/terraform-community-modules/tf_aws_vpc"

  azs                   = "${var.aws_azs}"
  name                  = "${var.vpc_name}"
  #-- networking
  cidr                  = "${var.vpc_cidr}"
  public_subnets        = "${var.vpc_public_subnets}"
  private_subnets       = "${var.vpc_private_subnets}"
  enable_dns_support    = "${var.enable_dns_support}"
  enable_dns_hostnames  = "${var.enable_dns_hostnames}"
  enable_nat_gateway    = "${var.enable_nat_gateway}"
  tags                  = "${merge(var.default_tags, map("VPC", "${var.vpc_name}"))}"
}
