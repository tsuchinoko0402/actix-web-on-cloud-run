# -----
# シークレットに関する定義
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret
# -----

# データベース名
resource "google_secret_manager_secret" "db_name" {
  secret_id = local.secret_id_db_name

  labels = {
    label = var.service_name
  }

  replication {
    automatic = true
  }
}

# データベースユーザー名
resource "google_secret_manager_secret" "db_user" {
  secret_id = local.secret_id_db_user

  labels = {
    label = var.service_name
  }

  replication {
    automatic = true
  }
}

# データベースのパスワード
resource "google_secret_manager_secret" "db_password" {
  secret_id = local.secret_id_db_password

  labels = {
    label = var.service_name
  }

  replication {
    automatic = true
  }
}
