#
# Project Name:: en_infra_aws
# File:: Makefile
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Helper that will help us manage our 'terraform' plans.

.PHONY: all test get info plan apply destroy

all: plan apply
test: plan

get:
	terraform get

info:
		for resursa in $$(terraform state list); do \
			echo -e "\n\n========================\n$$resursa\n------------------------"; \
			terraform state show $$resursa; \
		done

plan:
	terraform plan -var-file ../DevOpsVPC/infrastructure.conf

apply:
	terraform apply -var-file ../DevOpsVPC/infrastructure.conf

destroy:
	terraform plan -destroy -var-file ../DevOpsVPC/infrastructure.conf -out=statefiles/destroy.tfplan -state=statefiles/terraform.tfstate
	terraform apply statefiles/destroy.tfplan
	mv -f statefiles/terraform.tfstate statefiles/terraform.tfstate.old
	mv -f terraform.tfstate statefiles/terraform.tfstate
