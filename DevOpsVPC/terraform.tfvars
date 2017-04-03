#
# Project Name:: en_aws_infra
# File:: terraform.tfvars
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Variables overrides according to our needs.

#-- AWS region
aws_region = "us-east-1"
aws_azs = ["us-east-1a", "us-east-1b"] 

#-- Name
vpc_name = "TestTerraformVPC"

#-- Networking
vpc_cidr          = "10.10.0.0/16"
#-- We can provide multiple subnets that reside within the vpc_cidr
#vpc_private_subnets   = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
#vpc_public_subnets    = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
vpc_private_subnets   = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
vpc_public_subnets    = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]