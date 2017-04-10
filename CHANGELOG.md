Copyright (c) 2017-Preset Mihai Vultur, All Rights Reserved.

CHANGELOG
=========
## en_infra_aws

This file is used to list changes made in each version of the `en_infra_aws` project.

### Version 0.1.0
Initial implementation of the AWS VPC using terraform.
VPC
  - Public subnet
  - Private subnet
  - Separate security groups for public and private subnet
  - Uploaded public ssh-key to be used for connecting to EC2 instances
  - NAT instance assigned to the public subnet
  - Test Instance assigned to the private subnet
  - Working NAT

TO DO:
Refactoring

