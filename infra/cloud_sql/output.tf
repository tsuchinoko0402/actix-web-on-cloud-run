output "db_private_ip" {
  value = google_sql_database_instance.app.private_ip_address
}