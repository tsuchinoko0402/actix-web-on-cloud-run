# -----
# Cloud SQL の設定
#-----

# Secret Manager から必要な情報を取得する
data "google_secret_manager_secret_version" "db_name" {
  secret = local.secret_id_db_name
}

data "google_secret_manager_secret_version" "db_user" {
  secret = local.secret_id_db_user
}

data "google_secret_manager_secret_version" "db_password" {
  secret = local.secret_id_db_password
}

# VPC の設定を取得
data "terraform_remote_state" "vpc" {
  backend = "gcs"

  config = {
    bucket = "dev-tsuchinoko-tfstate"
    prefix = "actix-web-sample/vpc"
  }
}

# -----
# Cloud SQL 用にプライベート サービス アクセスを構成する
# https://cloud.google.com/sql/docs/postgres/configure-private-services-access#terraform
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#private-ip-instance

# IP アドレス範囲を割り振る
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.terraform_remote_state.vpc.outputs.vpc_id
}

# プライベート接続の作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.terraform_remote_state.vpc.outputs.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# -----
# Cloud SQL のインスタンスの作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
resource "google_sql_database_instance" "app" {
  name             = local.cloud_sql_instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.db_instance_machine_type
    disk_autoresize   = true
    availability_type = var.db_availability_type
    disk_type         = var.db_disk_type

    backup_configuration {
      enabled                        = var.db_backup_enabled
      point_in_time_recovery_enabled = var.db_point_in_time_recovery_enabled
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.terraform_remote_state.vpc.outputs.vpc_id // Specify VPC name
    }
  }

  deletion_protection = var.db_delete_protection
}

# データベースの作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database
resource "google_sql_database" "database" {
  name     = data.google_secret_manager_secret_version.db_name.secret_data
  instance = google_sql_database_instance.app.name
}

# ユーザーの作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user
resource "google_sql_user" "users" {
  name     = data.google_secret_manager_secret_version.db_user.secret_data
  instance = google_sql_database_instance.app.name
  password = data.google_secret_manager_secret_version.db_password.secret_data
}
