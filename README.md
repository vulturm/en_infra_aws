[//]: # (Describe the project's purpose.)

## en_infra_aws - Terraform

The `en_infra_aws` project goal is to automate the configuration of the AWS infrastructure used by our DevOps team.
This project uses Terraform to accomplish this goal.

[//]: # (TOC.)

- [About this project](#en_infra_aws---terraform)
- [What is terraform](#what-is-terraform)
- [Diagram for the infra created by this project](#diagram-for-the-infra-created-by-this-project)
- [Programming languages used](#programming-languages-used-hcl)
- [Supported Cloud Providers by this project](#supported-cloud-providers-by-this-project)
- [Dependencies](#dependencies)
- [Prerequisites](#prerequisites)
  -   [Remote state file](#remote-state-file)
- [Exposed configuration](#exposed-configuration)
  -  [VPC creation related](#vpc-creation-related)
  -  [Networking related](#networking-related)
  -  [Security related](#security-related)
  -  [Instances related](#instances-related)
  -  [Other variables](#other-variables)
- [Modules](#modules)
  -  [NAT](#nat----modulesnat)
  -  [VPN](#vpn----modulesvpn)
- [Usage](#usage)
  -  [Init Terraform](#terraform-init)
  -  [Inspect the infrastructure](#make-plan)
  -  [Apply changes](#make-apply)
  -  [Destroy managed infrastructure](#make-destroy)
  -  [Info about infrastructure state](#make-info)
  -  [Get modules](#make-get)
- [License](#license-and-authors)

[//]: # (Describe the technology used.)

## What is terraform

[Terraform][1] provides a common configuration to launch infrastructure from physical to cloud providers.

Simple file based configuration gives you a single view of your entire infrastructure.


## Diagram for the Infra created by this project
![AWS Cloud Diagram](https://raw.githubusercontent.com/xxmitsu/en_infra_aws/master/DevOpsVPC.png)

[//]: # (Identify programming languages used.)
## Programming languages used: HCL
* [HCL][2] is a structured configuration language that is both human and machine friendly (fully JSON compatible).
* [GNU Make Syntax][3]. We are using make with a set of rules to help us initiate the required terraform steps for the infrastructure automation.

[//]: # (Identify supported Cloud Providers.)

## Supported Cloud Providers by this project
|Cloud Provider | Implemented automation of the following resources |
|:--------:|:--------|
| `AWS` | <ul> <li>`VPC`</li><li>`Networking`: (Subnets, Routes, IGW, Security Groups)</li><li>ssh-key-upload</li><li>`NAT EC2` instance with `EIP`</li></ul>|

[//]: # (List Project dependencie.)

## Dependencies
|Dependency |Comments |
|:---------|:----------|
| `terraform` | This project was developed and tested using `Terraform v0.9.8` | 
| `make` | `Makefile` helper file was developed and tested using `GNU Make 3.82` |


[//]: # (List Project Prerequisites.)
## Prerequisites
You need to specify credentials profile in `~/.aws/credentials` by `aws configure --profile default` option. Terraform will use those credentials.
```bash
$ cat ~/.aws/credentials
[default]
aws_access_key_id = someSecretKey
aws_secret_access_key = someSecretPassKey
```

You need to install terraform by downloading the [appropriate package][4] for your operating system then extract the zip archive.<br />
Terraform runs as a single binary named terraform.

### Remote state file
To prevent stack corruption when terraform is used by multiple teams, remote storate of the state file was implemented.
To provision AWS resource required for remote state storage run `make apply` in `RemoteState` directory.
Name of the created `S3 Bucket` and `DynamoDB table` can be configured from `infrastructure.conf`.
Statefile configuration cannot contain interpolations. If the default values will be changed, the `DevOpsVPC/state.tf` file will also have to be synced manually.

## Exposed configuration
Project's data that can vary from one environment to another was exposed using variables in the `infrastructure.conf` file.
This file is automatically loaded when invoking terraform by the `Makefile wrapper`. <br />
Refer to the `variables.tf` file in the `DevOpsVPC` directory for the default values.

[//]: # (Segment attributes by category.)

[//]: # (### Top Level Variables)
[//]: # (|Variable |Type |Description |Comments |)
[//]: # (|:---------|:----|:-----------|:--------|)
[//]: # (| | | | |)

### VPC creation related
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `vpc_name` | *String* | Name of our `VPC`. | Mandatory |
| `aws_region` | *String* | AWS region used for our infrastructure deployment. | Optional, defaults to `us-east-1` if not specified |
| `aws_azs` | *List* | AWS Availability zones list in which to distribute subnets. | Mandatory based on the `aws_region` |

### Networking related
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `vpc_cidr` | *String* | The `CIDR block` for our VPC. | Mandatory |
| `vpc_private_subnets` | *List* | List of `CIDR blocks` for our private subnets.<br /> Must be in range of the `vpc_cidr`. | Mandatory |
| `vpc_public_subnets` | *List* | List of `CIDR blocks` for our public subnets.<br /> Must be in range of the `vpc_cidr`. | Mandatory |
| `enable_dns_support` | *Boolean* | Should be `true` if you want to use private DNS within the VPC. | Optional, defaults to `true` |
| `enable_dns_hostnames` | *Boolean* | Should be true if you want to use private DNS within the VPC. | Optional, defaults to `true` |
| `nat_inbound_ports` | *String* | Comma separated list of ports that will be opened on the public facing IP of the NAT instance.<br> Eg. SSH+VPN ports | Optional, defaults to `22,443` |

### Security related
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `ssh_user` | *String* | Name of the SSH used used to connect with during instance provisioning | Mandatory |
| `ssh_public_key_name` | *String* | Name of the `SSH Key` that will be uploaded into AWS and used for SSH into instances. | Mandatory |
| `ssh_public_key_file` | *String* | Location for the public ssh key file on your local workstation. | Mandatory |

### Instances related
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `ec2_custom_image` | *String* | Name of the AWS AMI to be used when spawning EC2 instance. Takes precedence over `ec2_os` | Optional | 
| `ec2_os` | *String* | OS version that will be used to find AMI image for EC2 creation. | Mandatory |

### Other variables
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `default_tags` | *Map* | A map of tags to add to all resources for audit, identification, etc. | Optional |

---
[//]: # (Terraform Modules that this project provides.)

[//]: # (### Exposed variables to configure the module.)
[//]: # (|Variable |Type |Description |Comments |)
[//]: # (|:---------|:----|:-----------|:--------|)
[//]: # (| | | | |)

## Modules
### `NAT` -- `modules/nat/`
- Terraform module used to configure a EC2 instance that will serve as NAT Gateway/purpose for the instances that reside in the private subnet.
### Exposed variables:
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `instance_name` | *String* | Name of the Nat instance that will appear in AWS Console. | Mandatory |
| `instance_type` | *String* | Type of the instance used that will serve as NAT Purpose. | Optional |
| `vpc_name` | *String* | VPC name that the created instance will be assigned to. | Mandatory |
| `vpc_id` | *String* | VPC ID that the instance will be assigned to. | Mandatory |
| `subnet_id` | *String* | Subnet ID that will be `used for instance interface` creation. Eg. Public Subnet ID. | Mandatory |
| `private_subnets_cidr` | *String* | `CIDR of the private subnet` that the instance will do `NAT translation` for. | Mandatory |
| `ami_id` | *String* | `AWS AMI ID` used for instance creation. | Mandatory |
| `user_data` | *String* | `user_data` config used during instance creation. | Mandatory |
| `sgs` | *String* | `Security groups IDs` that will be assigned to the NAT instance. | Mandatory |
| `key_name` | *String* | `AWS Name of the ssh key` to be used during instance provisioning. | Mandatory |
| `private_key_file` | *String* | Location for the private ssh key file that will be used to connect to the instance during provisioning. | Mandatory |
| `number_of_instances` | *Integer* | Number of NAT instances to spawn. | Optional, defaults to `1` |
| `root_volume_size` | *Integer* | Size in GBytes for the NAT instance root volume. | Optional, defaults to `8` |
| `inbound_ports` | *String* | Comma separated list of ports that will be opened on the public facing IP of the NAT instance. Eg. SSH+VPN ports. | Optional |


### `VPN` -- `modules/vpn/`
- Terraform module used to configure OpenVPN server. It uses a chef cookbook to accomplish this goal.
### Exposed variables:
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
| `ssh_user` | *String* | Name of the ssh user used for configuring the remote instances. | Mandatory |
| `private_key_file` | *String* | Path to private key file used in combination with ssh_user. | Mandatory |
| `ovpn_cookbook_ver` | *String* | Version of the custom chef cookbook used to configure the OpenVPN service. | Optional, defaults to `1.1.0` |
| `vpn_ip` | *String* | IP Address of the OpenVPN server. It also connects to this IP during server configuration. | Mandatory |
| `vpn_port` | *String* | Port that the OpenVPN server will listen to. | Mandatory |
| `vpn_proto` | *String* | Protocol used for VPN transport: `udp` or `tcp`.. | Optional, defaults to `tcp` |
| `vpc_cidr` | *String* | CIDR block we want the OpenVPN server to add a route to facilitate traffic | Mandatory |

---
## **Usage**

[//]: # (Identify the commands -- that are meant to be called by a user.)

## Terraform commands are wrapped by the `Makefile` script.
### Terraform init
This will solve module dependencies and configure terraform to use remote state. For provisioning of the resources required for remote state configuration, see [Remote state file][5]. 

### make plan
Will read our custom `infrastructure.conf`, process the tf files then compare the local tfstate with the remote state of the infrastructure and will tell you what needs to be done without actually doing it.

### make apply
Will read our custom `infrastructure.conf`, will process the tf filse and send the commands to `AWS API` to provision the infrastructure.
Will save a copy of the previous statefile in the `statefiles/beforeapply_$$(date +"%s").backup` location.

### make destroy
Will read our custom `infrastructure.conf`, do a `terraform plan -destroy`, which creates a planfile in `statefiles/destroy.tfplan` then will `apply that destroy plan`.<br />
`**WARNING!**` This command destroys the entire `terraform controlled` infrastructure without any notice! Use it with care in production.

### make info
Will parse the list of the `terraform state` and show a detailed human readable output so that we could inspect our infrastructure.

### make get
Gets any modules prior to using them.


---
## **License and Authors**

Maintainer:       'Mihai Vultur'<br>
License:          'GPL v3'<br>


[1]: http://www.terraform.io/ "Terraform"
[2]: https://github.com/hashicorp/hcl "HCL"
[3]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html "Make"
[4]: https://www.terraform.io/downloads.html "Download Terraform"
[5]: #remote-state-file "Prerequisites - Remote state file"
