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


module "vpc"  {
  source = "github.com/hashicorp/best-practices//terraform/modules/aws/network/vpc"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"
}

}
