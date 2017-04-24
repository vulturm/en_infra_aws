#
# Project Name:: en_infra_aws
# Module:: NAT
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   Configures Elastic IP that will be associated with the NAT instance
#

resource "aws_eip" "NatInstance" {
    instance = "${aws_instance.NatInstance.id}"
    vpc      = true
}
#--
resource "aws_eip_association" "eip_assoc_NatInstance" {
  instance_id   = "${aws_instance.NatInstance.id}"
  allocation_id = "${aws_eip.NatInstance.id}"
}
