#
# Project Name:: en_infra_aws
# Module:: VPN - variables file
#
# Copyright (C) 2017 - Present
# Author: 'Mihai Vultur <mihai.vultur@endava.com>'
#
# All rights reserved
#
# Description:
#   VPN module specific variables
#

variable "ssh_user" {
  description = "Name of the ssh user used for configuring the remote instances"
  type = "string"
}

variable "private_key_file" {
  description = "Path to private key file used in combination with ssh_user"
}

variable "ovpn_cookbook_ver" {
  description = "Version of the custom chef cookbook used to configure the OpenVPN service."
  default = "1.1.0"
}

variable "vpn_ip" {
  description = "IP Address of the OpenVPN server"
}

variable "vpn_port" {
  description = "Port that the OpenVPN server will listen to."
  default  = "1194"
}

variable "vpn_proto" {
  description = "Protocol used for VPN transport: 'udp' or 'tcp'."
  default  = "tcp"
}

variable "vpc_cidr" {
  description = "CIDR block we want the OpenVPN server to add a route to facilitate traffic."
}
