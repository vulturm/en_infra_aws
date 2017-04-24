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
#   Module specific variables
#

variable "instance_name" {
  description = "Name of the Nat instance that will appear in AWS Console"
}
variable "instance_type" {
  description = "Type of the instance used that will serve as NAT Purpose"
  default = "t2.micro"
}
variable "vpc_name" {
  description = "VPC name that the created instance will be assigned to"
}
variable "vpc_id" {
  description = "VPC ID that the instance will be assigned to"
}
variable "subnet_id" {
  description = "Subnet ID that will be used for instance interface creation. Eg. Public Subnet ID."
}
variable "private_subnets_cidr" {
  description = "CIDR of the private subnet that the instance will do NAT translation for"
}
variable "ami_id" {
  description = "AWS AMI ID used for instance creation"
}
variable "user_data" {
  description = "user_data config used during instance creation"
}
variable "sgs" {
  description = "Security groups IDs that will be assigned to the NAT instance"
}
variable "key_name" {
  description = "AWS Name of the ssh key to be used during instance provisioning"
}
variable "private_key_file" {
  description = "Path to private key file use to connect to the NAT Instance"
}

variable "number_of_instances" {
  description = "Number of instances to start"
  default = 1
}

variable "root_volume_size" {
    description = "Size of the root volume"
    default = 8
}

variable "inbound_ports" {
  description = "Comma separated list of ports that will be opened on the public facing IP of the NAT instance"
  default  = "22,443"
}
