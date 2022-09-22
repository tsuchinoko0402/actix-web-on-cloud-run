variable "project_id" {
  type    = string
  default = "tsuchinoko"
}

variable "service_name" {
  type    = string
  default = "actix-web-sample"
}

variable "region" {
  type    = string
  default = "us-central1"
}

locals {
  secret_id_db_name     = "${var.service_name}-db-name"
  secret_id_db_user     = "${var.service_name}-db-user"
  secret_id_db_password = "${var.service_name}-db-password"
}