# The service layer is created by this module by default; re-using an
# existing service is the opt-in path (create_service = false).
resource "aiven_clickhouse" "this" {
  count = var.create_service ? 1 : 0

  project                = var.project
  service_name           = var.service_name
  cloud_name             = var.cloud_name
  plan                   = var.plan
  termination_protection = var.service_termination_protection
}

resource "aiven_clickhouse_database" "this" {
  project                = var.project
  service_name           = var.create_service ? aiven_clickhouse.this[0].service_name : var.service_name
  name                   = var.database_name
  termination_protection = var.termination_protection
}
