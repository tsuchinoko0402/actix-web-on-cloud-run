# ----------
# ネットワークの設定
# ----------

# ----- 以下、Terraform の公式の example を参考にネットワークの設定作成 -----
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector#example-usage---cloudrun-vpc-access-connector

# Serverless VPC Access API の有効化
resource "google_project_service" "vpcaccess_api" {
  provider = google-beta

  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

# VPC の作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
}

# サブネットの作成
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "vpc" {
  name                     = local.subnet_name
  ip_cidr_range            = var.subnet_cidr_range
  network                  = google_compute_network.vpc.self_link
  region                   = var.region
  private_ip_google_access = true
}

# VPC アクセスコネクターの作成
# CloudRun からプライベートな Cloud SQL に接続するためには必須
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector
resource "google_vpc_access_connector" "connector" {
  provider = google-beta

  name          = local.vpc_connector_name
  region        = var.region
  ip_cidr_range = var.vpc_connector_cidr_range
  network       = google_compute_network.vpc.name
  machine_type  = var.vpc_connector_machine_type
  min_instances = 2
  max_instances = 10

  depends_on = [google_project_service.vpcaccess_api]
}

# Cloud Router の設定
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector
resource "google_compute_router" "router" {
  provider = google-beta

  name    = local.router_name
  region  = var.region
  network = google_compute_network.vpc.id
}

# NAT の設定
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "router_nat" {
  provider = google-beta

  name                               = local.nat_name
  region                             = var.region
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}
