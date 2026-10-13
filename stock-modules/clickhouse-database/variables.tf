variable "project" {
  description = "Aiven console project the ClickHouse service lives in."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "project must be lowercase letters, numbers and hyphens."
  }
}

variable "create_service" {
  description = "Create the Aiven ClickHouse service layer as part of this module (the default). Set false to re-use an existing service named service_name instead; the service is then referenced, never managed."
  type        = bool
  default     = true
}

variable "service_name" {
  description = "Name of the Aiven ClickHouse service. Created by this module by default; with create_service = false it must name an existing service to re-use."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "service_name must be lowercase letters, numbers and hyphens."
  }
}

variable "cloud_name" {
  description = "Cloud the service is created on; only used when create_service is true. SEFE services run BYOC on Azure uksouth: custom-sefe-nprod-workload-azure-uksouth (non-prod, default) or custom-sefe-prod-workload-azure-uksouth (prod)."
  type        = string
  default     = "custom-sefe-nprod-workload-azure-uksouth"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cloud_name))
    error_message = "cloud_name must be lowercase letters, numbers and hyphens."
  }
}

variable "plan" {
  description = "Aiven service plan for the created service; only used when create_service is true. Default is the smallest production-grade ClickHouse plan."
  type        = string
  default     = "startup-16"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.plan))
    error_message = "plan must be lowercase letters, numbers and hyphens."
  }
}

variable "service_termination_protection" {
  description = "Client-side deletion protection on the created service; only used when create_service is true. Secure by default; set false only for throwaway environments."
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the ClickHouse database to create. Cannot be changed after creation (forces recreation)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,255}$", var.database_name))
    error_message = "database_name must be 1-255 characters of letters, numbers, underscores and hyphens."
  }
}

variable "termination_protection" {
  description = "Client-side deletion protection preventing Terraform from destroying the database. Secure by default; set false only for throwaway environments."
  type        = bool
  default     = true
}
