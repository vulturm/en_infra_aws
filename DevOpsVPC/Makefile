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
test: plan

get:
	terraform get

plan:
	terraform plan -var-file infrastructure.conf -out terraform.tfplan | tee -a logs/plan.log

apply:
	terraform apply -var-file infrastructure.conf -backup terraform.backup | tee -a logs/apply.log

destroy:
	terraform plan -destroy -var-file infrastructure.conf -out terraform.tfplan | tee -a logs/destroy.log
	terraform apply terraform.tfplan | tee -a logs/destroy.log
