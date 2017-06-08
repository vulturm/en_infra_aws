#
# Project Name:: en_infra_aws
# File:: state.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Configure terraform to store it's state file remote
#

#--
terraform {
  backend "s3" {
    bucket     = "en-infra-aws-remote-state"
    key        = "en_infra_aws/terraform.tfstate"
    region     = "us-east-1"
    lock_table = "en-infra-aws-remote-state-lock"
  }
}
