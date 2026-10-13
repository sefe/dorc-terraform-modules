# The service layer is created by this module by default; re-using an
# existing service is the opt-in path (create_service = false).
resource "aiven_pg" "this" {
  count = var.create_service ? 1 : 0

  project                = var.project
  service_name           = var.service_name
  cloud_name             = var.cloud_name
  plan                   = var.plan
  termination_protection = var.service_termination_protection
}

resource "aiven_pg_database" "this" {
  project       = var.project
  service_name  = var.create_service ? aiven_pg.this[0].service_name : var.service_name
  database_name = var.database_name
  lc_collate    = var.lc_collate
  lc_ctype      = var.lc_ctype

  termination_protection = var.termination_protection
}
