#
# Project Name:: en_infra_aws
# File:: vpn.tf
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@___.com>'
#
# All rights reserved
#
# Description:
#   Uses 'VPN module' to configure a OpenVPN server on the remote instance
#

module "vpn" {
  source                = "../modules/vpn"
  vpn_ip                = "${module.nat.public_ip}"
  vpn_port              = "${var.vpn_port}"
  vpc_cidr              = "${var.vpc_cidr}"
  ssh_user              = "${var.ssh_user}"
  #-- assuming 'private key name' by removing the '.pub' extension
  private_key_file      = "${replace(var.ssh_public_key_file, ".pub", "")}"
}
