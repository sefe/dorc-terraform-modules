output "database_id" {
  description = "ID of the PostgreSQL database (project/service_name/database_name)."
  value       = aiven_pg_database.this.id
}

output "database_name" {
  description = "Name of the created PostgreSQL database."
  value       = aiven_pg_database.this.database_name
}

output "project" {
  description = "Aiven project the database belongs to."
  value       = aiven_pg_database.this.project
}

output "service_name" {
  description = "PostgreSQL service the database belongs to."
  value       = aiven_pg_database.this.service_name
}
