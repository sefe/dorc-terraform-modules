# Stock module: clickhouse-database

| Field | Value |
|---|---|
| **Owner** | DOrc platform team |
| **Status** | Active |
| **Category** | Data |
| **Provider** | `aiven/aiven >= 4.1.1, < 5.0.0` |
| **Terraform** | `>= 1.5.0` |

Creates a ClickHouse database on an Aiven ClickHouse service. The module **creates the service layer by default**; re-using an existing service is the opt-in path (`create_service = false`), in which case the service is referenced, never managed.

## SEFE BYOC placement

SEFE Aiven services run **BYOC** (bring-your-own-cloud) on Azure uksouth. Created services default to the non-prod custom cloud; nodes live in SEFE's Azure estate:

| Environment | Custom cloud (`cloud_name`) | Azure resource group |
|---|---|---|
| Non-prod (default) | `custom-sefe-nprod-workload-azure-uksouth` | `rg-np-aiven-1-uks` (SMT-NP) |
| Prod | `custom-sefe-prod-workload-azure-uksouth` | `rg-pr-aiven-1-uks` (SMT-PR) |

The resource groups are informational — Aiven manages the nodes.

## Authentication

The Aiven provider authenticates with an API token. Per the module contract the module declares no provider block; supply the token via the `AIVEN_TOKEN` environment variable on the runner, or per DOrc environment with the secure `TerraformAivenApiToken` environment property (injected as `AIVEN_TOKEN` on the terraform process only).

## Inputs

| Name | Type | Required | Description |
|---|---|:-:|---|
| `project` | string | yes | Aiven console project (lowercase alnum + hyphens). |
| `create_service` | bool | no (`true`) | Create the service layer; set `false` to re-use an existing service. |
| `service_name` | string | yes | Service name — created by default, or the existing service to re-use. |
| `cloud_name` | string | no (non-prod custom cloud) | Cloud for the created service; see BYOC placement. |
| `plan` | string | no (`startup-16`) | Aiven plan for the created service. |
| `service_termination_protection` | bool | no (`true`) | Delete protection on the created service. |
| `database_name` | string | yes | Database name; immutable (change forces recreation). |
| `termination_protection` | bool | no (`true`) | Client-side delete protection. Secure by default; opt out for throwaway environments. |

## Outputs

`database_id`, `database_name`, `project`, `service_name`.

## Secret handling

This module takes no secret inputs and outputs no credentials. ClickHouse users/grants are managed separately (`aiven_clickhouse_user` / `aiven_clickhouse_grant`).

## Example

See `examples/basic/`.

## Versioning

Released as Git tag `stock-modules/clickhouse-database/v<X.Y.Z>`.
