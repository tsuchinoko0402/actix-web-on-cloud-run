# -----
# Cloud Run の設定
# -----

# VPC の設定を取得
data "terraform_remote_state" "vpc" {
  backend = "gcs"

  config = {
    bucket = "dev-tsuchinoko-tfstate"
    prefix = "actix-web-sample/vpc"
  }
}

# DB の設定を取得
data "terraform_remote_state" "cloud_sql" {
  backend = "gcs"

  config = {
    bucket = "dev-tsuchinoko-tfstate"
    prefix = "actix-web-sample/cloud-sql"
  }
}


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

# Cloud Run のサービスの設定
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service
resource "google_cloud_run_service" "app" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.gcr_image
        ports {
          container_port = 8080
        }
        env {
          name  = "SERVER_ADDRESS"
          value = "0.0.0.0"
        }
        env {
          name  = "DATABASE_URL"
          value = "postgres://${data.google_secret_manager_secret_version.db_user.secret_data}:${data.google_secret_manager_secret_version.db_password.secret_data}@${data.terraform_remote_state.cloud_sql.outputs.db_private_ip}:5432/${data.google_secret_manager_secret_version.db_name.secret_data}"
        }
      }
    }

    metadata {
      annotations = {
        # Use the VPC Connector
        "run.googleapis.com/vpc-access-connector" = data.terraform_remote_state.vpc.outputs.connector_name // Specify VPC connector
        # all egress from the service should go through the VPC Connector
        "run.googleapis.com/vpc-access-egress" = "all"
        # If this resource is created by gcloud, this client-name will be gcloud
        "run.googleapis.com/client-name" = "terraform"
        # Disallow direct access from IP
        # "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      # For update of gcloud cli version
      template[0].metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }

  autogenerate_revision_name = true
}

# 認証なしアクセスを許可するためのポリシー
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# 認証なしのアクセスを可能にする
# 実行には Terraform 実行するための IAM ロールに Cloud Run の管理者権限が必要
resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.app.location
  project  = google_cloud_run_service.app.project
  service  = google_cloud_run_service.app.name

  policy_data = data.google_iam_policy.noauth.policy_data
}