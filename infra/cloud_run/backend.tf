terraform {
  # https://www.terraform.io/language/settings/backends/gcs
  backend "gcs" {
    bucket = "dev-tsuchinoko-tfstate"
    prefix = "actix-web-sample/cloud-run"
  }
}