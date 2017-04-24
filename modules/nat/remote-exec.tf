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
#   Execute the required configuration for the EC2 instance to
#     convert it into a fully functional NAT instance
#

#-- workarround adding a triggered resource
#-- because of a circular dependency between
#-- eip and aws_instance
resource "null_resource" "preparation" {
  triggers {
    association_ip_address = "${aws_eip_association.eip_assoc_NatInstance.id}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo iptables -t nat -C POSTROUTING -o eth0 -s ${var.private_subnets_cidr} -j MASQUERADE 2> /dev/null || sudo iptables -t nat -A POSTROUTING -o eth0 -s ${var.private_subnets_cidr} -j MASQUERADE",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.ipv4.conf.eth0.send_redirects=0' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=131072' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p"
    ]
    connection {
      host        = "${aws_eip.NatInstance.public_ip}"
      user        = "centos"
      timeout     = "30s"
      private_key = "${file(var.private_key_file)}"
    }
  }
}

