#
# Project Name:: en_infra_aws
# File:: outputs.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Outputs the following variables to the user.
#

#-- EC2 Instances
output "NAT_instance_id" {
    value = "${aws_instance.NatInstance.id}"
}

output "NAT_private_ip" {
    value = "${aws_instance.NatInstance.private_ip}"
}

output "NAT_public_ip" {
    value = "${aws_eip.NatInstance.public_ip}"
}

#--
output "TEST_instance_id" {
    value = "${aws_instance.TestInstance.id}"
}

output "TEST_private_ip" {
    value = "${aws_instance.TestInstance.private_ip}"
}
