#
# Project Name:: en_infra_aws
# Module:: NAT
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Output the parameters returned by NAT instance 
#     handy to be reused by other resources.
#

output "instance_id" {
    value = "${aws_instance.NatInstance.id}"
}

output "private_ip" {
    value = "${aws_instance.NatInstance.private_ip}"
}

output "public_ip" {
    value = "${aws_eip.NatInstance.public_ip}"
}

output "instance_zone" {
    value = "${aws_instance.NatInstance.availability_zone}"
}

