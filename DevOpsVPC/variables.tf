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
#   Variables we're using with their description.
#   If a default value is set, the variable is optional.
#   Otherwise, the variable is required.

#-- Naming
variable "aws_region" {
  description = "AWS region"
  default = "us-east-1" 
}
variable "aws_azs" {
  description = "AWS Availability zones"
}
variable "vpc_name" {
  description = "Name of the VPC"
}

#-- Networking
variable "vpc_cidr"        {
  description = "The CIDR block for our VPC"
}
variable "vpc_private_subnets" {
  description = "The CIDR blocks for our private subnets"
 }
variable "vpc_public_subnets"  {
  description = "The CIDR blocks for our public subnets"
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default = false
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default = false
}

#-- Tags for accounting
variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = "map"
  default = {
    "creation-author" = "mike"
    "provisioner" = "terraform"
  }
}
