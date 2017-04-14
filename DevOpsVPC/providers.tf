#
# Project Name:: en_infra_aws
# File:: providers.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Sets up aws account access credentials
#    and regional preference
#

#--
provider "aws" {
  region                    = "${var.aws_region}"
  #-- must be fullpath, ~ is not evaluated
  shared_credentials_file   = "/home/vagrant/.aws/credentials"
}
