variable "project" {
  description = "Aiven console project the PostgreSQL service lives in."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "project must be lowercase letters, numbers and hyphens."
  }
}

variable "service_name" {
  description = "Name of the existing Aiven PostgreSQL service the database is created in. The service is referenced, never managed, by this module."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "service_name must be lowercase letters, numbers and hyphens."
  }
}

variable "database_name" {
  description = "Name of the PostgreSQL database to create. Cannot be changed after creation (forces recreation)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,40}$", var.database_name))
    error_message = "database_name must be 1-40 characters of letters, numbers, underscores and hyphens."
  }
}

variable "lc_collate" {
  description = "Default string sort order (LC_COLLATE) of the database. Cannot be changed after creation."
  type        = string
  default     = "en_US.UTF-8"
}

variable "lc_ctype" {
  description = "Default character classification (LC_CTYPE) of the database. Cannot be changed after creation."
  type        = string
  default     = "en_US.UTF-8"
}

variable "termination_protection" {
  description = "Client-side deletion protection preventing Terraform from destroying the database. Secure by default; set false only for throwaway environments."
  type        = bool
  default     = true
}
