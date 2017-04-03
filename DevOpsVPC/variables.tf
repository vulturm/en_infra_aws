#
# Project Name:: en_aws_infra
# File:: variables.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Variables we're using.
#   If a default value is set, the variable is optional.
#   Otherwise, the variable is required.

variable "name" {}
variable "vpc_cidr" {}

variable "name" {
  default = "terraform-test-vpc"
}

variable "region" {
  description = "AWS region"
  default = "us-east-1"
}

variable "cidr" {}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default = false
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default = false
}

variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default = {
    "creation-author" = "mike"
    "provisioner" = "terraform"
  }
}