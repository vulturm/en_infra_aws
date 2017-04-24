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
#   Provide the possibility to open some ports on the
#     instance public facing IP. Usefull for ssh (jump host) or VPN.
#

resource "aws_security_group" "DefaultNAT" {
  vpc_id      = "${var.vpc_id}"
  description = "Default VPC security group for NAT instance"

  tags = "${merge(map("Provisioner", "terraform"), map("VPC", var.vpc_name), map("Name", format("%s_SC_DefaultNAT", var.vpc_name)))}"
}
#--
resource "aws_security_group_rule" "NATRule" {
  count = "${length(split(",",var.inbound_ports))}"
  type = "ingress"
  from_port = "${element(split(",", var.inbound_ports), count.index)}"
  to_port = "${element(split(",", var.inbound_ports), count.index)}"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.DefaultNAT.id}"
}
