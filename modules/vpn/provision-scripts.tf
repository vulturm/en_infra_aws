#
# Project Name:: en_infra_aws
# Module:: VPN
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   VPN module configures a OpenVPN server on the remote instance
#

data "template_file" "custom_attrib" {
  template = "${file("../files/provisioning/vpn_custom_attrib.tpl")}"
  vars {
    push_routes_array = "${cidrhost(var.vpc_cidr, 0)} ${cidrnetmask(var.vpc_cidr)}"
    gateway_address = "${var.vpn_ip}"
    vpn_port = "${var.vpn_port}"
    vpn_proto = "${var.vpn_proto}"
    client_prefix = "devops_cluj"
  }
}

#-- Currently, as of terraform 0.9.2, it doesn't allow us
#-- to specify a common connection block to be used for all
#-- the provisioners, so we have to repeat that block for 
#-- each provisioner

resource "null_resource" "preparation" {
  triggers {
    always = "${uuid()}"
  }
  #--
  provisioner "remote-exec" {
    inline = [
      "rm -rf /home/${var.ssh_user}/provision",
      "curl -L --create-dirs -o /home/${var.ssh_user}/provision/en_ovpn.tar.gz https://github.com/xxmitsu/en_ovpn/archive/EN_OVPN-${var.ovpn_cookbook_ver}.tar.gz",
      "tar -xzf /home/${var.ssh_user}/provision/en_ovpn.tar.gz -C /home/${var.ssh_user}/provision/",
      "cat > /home/centos/provision/en_ovpn-EN_OVPN-${var.ovpn_cookbook_ver}/provision/custom_attrib.json <<EOL\n${data.template_file.custom_attrib.rendered}\nEOL",
      "/home/centos/provision/en_ovpn-EN_OVPN-${var.ovpn_cookbook_ver}/provision/provision.sh /home/centos/provision/en_ovpn-EN_OVPN-${var.ovpn_cookbook_ver}/provision/"
    ]
    connection {
      host        = "${var.vpn_ip}"
      user        = "${var.ssh_user}"
      timeout     = "30s"
      private_key = "${file(var.private_key_file)}"
    }
  }
}

