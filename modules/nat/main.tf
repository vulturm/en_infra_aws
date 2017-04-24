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
#   Creation of the EC2 instance that will serve as NAT Gateway
#

resource "aws_instance" "NatInstance" {
  count                       = "${var.number_of_instances}"
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(split(",", var.subnet_id), count.index)}"
  key_name                    = "${var.key_name}"

  vpc_security_group_ids = [
    "${split(",", var.sgs)}"
  ]

  source_dest_check           = false

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags = "${merge(map("ManageRunningTime", "WorkingHoursStop"), map("Provisioner", "terraform"), map("VPC", var.vpc_name), map("Name", format("%s_%s", var.vpc_name, var.instance_name)))}"

}

