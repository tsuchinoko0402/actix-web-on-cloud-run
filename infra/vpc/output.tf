output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "connector_name" {
  value = google_vpc_access_connector.connector.name
}