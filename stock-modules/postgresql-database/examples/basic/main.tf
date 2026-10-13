module "postgresql_database" {
  source = "../.."

  project       = "trading-analytics"
  service_name  = "pg-analytics-dev"
  database_name = "appdb"

  # The module creates the service layer by default. Re-using an existing
  # service instead is the opt-in path:
  # create_service = false

  # Throwaway example environment; keep protection on in production.
  termination_protection         = false
  service_termination_protection = false
}
