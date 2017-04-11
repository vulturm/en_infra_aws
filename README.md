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
- [Exposed configuration](#exposed-configuration)
  -  [VPC creation related](#vpc-creation-related)
  -  [Networking related](#networking-related)
  -  [Security related](#security-related)
  -  [Instances related](#instances-related)
  -  [Other variables](#other-variables)
- [Usage](#usage)
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
| `terraform` | This project was developed and tested using `Terraform v0.9.2` | 
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

## Exposed configuration
Project's data that can vary from one environment to another was exposed using variables in the `infrastructure.conf` file.
This file is automatically loaded when invoking terraform by the `Makefile wrapper`. <br />
Refer to the `variables.tf` file in the `DevOpsVPC` directory for the default values.

[//]: # (Segment attributes by environment if multiple environments are created)

[//]: # (Copy section for multiple separated environments.)

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

### Security related
|Variable |Type |Description |Comments |
|:---------|:----|:-----------|:--------|
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
## **Usage**

[//]: # (Identify the commands -- that are meant to be called by a user.)

## Terraform commands are wrapped by the `Makefile` script.
### make plan
Will read our custom `infrastructure.conf`, process the tf files then compare the local tfstate with the remote state of the infrastructure and will tell you what needs to be done without actually doing it.

### make apply
Will read our custom `infrastructure.conf`, will process the tf filse and send the commands to `AWS API` to provision the infrastructure.

### make destroy
Will read our custom `infrastructure.conf`, do a `terraform plan` then `terraform destroy`.<br />
`**WARNING!**` This command destroys the entire `terraform controlled` infrastructure without any notice! Don't use it in production.

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
