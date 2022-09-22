variable "subnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_connector_cidr_range" {
  type    = string
  default = "10.8.0.0/28"
}

variable "vpc_connector_machine_type" {
  type    = string
  default = "f1-micro"
}

locals {
  vpc_name           = "${var.service_name}-vpc"
  subnet_name        = "${var.service_name}-subnet"
  vpc_connector_name = "${local.vpc_name}-con"
  router_name        = "${local.vpc_name}-router"
  nat_name           = "${local.vpc_name}-nat"
}