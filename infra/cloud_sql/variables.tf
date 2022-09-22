variable "db_disk_type" {
  type    = string
  default = "PD_HDD"
}

variable "db_backup_enabled" {
  type    = bool
  default = false
}

variable "db_point_in_time_recovery_enabled" {
  type    = bool
  default = false
}

variable "db_delete_protection" {
  type    = bool
  default = false
}

variable "db_instance_machine_type" {
  type    = string
  default = "db-f1-micro"
}

variable "db_availability_type" {
  type = string
  default = "ZONAL"
}

locals {
  cloud_sql_instance_name = "${var.project_id}-instance"
  cloud_sql_database_name = "${var.service_name}-db"
}