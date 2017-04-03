#
# Project Name:: en_aws_infra
# File:: Makefile
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Helper that will help us manage our 'terraform' plans.

.PHONY: all plan apply destroy

all: plan apply

plan:
	terraform plan -var-file terraform.tfvars -out terraform.tfplan

apply:
	terraform apply -var-file terraform.tfvars

destroy:
	terraform plan -destroy -var-file terraform.tfvars -out terraform.tfplan
	terraform apply terraform.tfplan
