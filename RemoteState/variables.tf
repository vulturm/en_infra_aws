
# Project Name:: en_infra_aws
# File:: variables.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Variables we're using with their description.
#   If a default value is set, the variable is optional.
#   Otherwise, the variable is required.

#-- Naming
variable "aws_region" {
  description = "AWS region"
  type = "string"
  default = "us-east-1"
}

#--
variable "statefile_bucket" {
  description = "Name of the S3 bucket where we will store our statefile"
  type = "string"
  default = "en-infra-aws-remote-state"
}

#--
variable "statefile_dynamo" {
  description = "Name of the DynamoDB table where we will store our locking"
  type = "string"
  default = "en-infra-aws-remote-state-lock"
}
