module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}
