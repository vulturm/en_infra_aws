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
#   Holds our module import definitions.


provider "aws" {
  region  = "${var.region}"
  shared_credentials_file="~/.aws/credentials"
}

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "10.10.0.0/16"
}
