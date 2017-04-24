Copyright (c) 2017-Preset Mihai Vultur, All Rights Reserved.

CHANGELOG
=========
## en_infra_aws

This file is used to list changes made in each version of the `en_infra_aws` project.

### Version 1.4.0
Separate NAT instance configuration using a 'terraform module'.

### Version 1.3.0
Move terraform generated files: (.tfstate, .tfplan) into a separate `statefiles` directory.

### Version 1.2.1
Fixed outputing NATInstance public_ip by separating the creation and assignement phases.
Fixed remote-exec provisioning retry sequence - now is triggered by the assignement 
 of the EIP instead of the instance creation and retry until the resource is ready.

### Version 1.2.0
`main.tf` config was split in multiple `.tf` files according to their purpose.

### Version 1.1.0
Provide the possibility to specify custom AMI name.
Takes precedence over the AMI autodetection feature. 

### Version 1.0.0
Initial implementation of the AWS VPC using terraform.
VPC
  - Public subnet
  - Private subnet
  - Separate security groups for public and private subnet
  - Uploaded public ssh-key to be used for connecting to EC2 instances
  - NAT instance assigned to the public subnet
  - Test Instance assigned to the private subnet
  - Working NAT
  - Automatic detection of the CentOS AMI

TO DO:
Refactoring

