# Stock module: kafka-topic

| Field | Value |
|---|---|
| **Owner** | DOrc platform team |
| **Status** | Active |
| **Category** | Messaging |
| **Provider** | `aiven/aiven >= 4.42.0, < 5.0.0` |
| **Terraform** | `>= 1.5.0` |

Creates a single Kafka topic on an **existing** Aiven Kafka service, composing the topic name from the SEFE Kafka messaging standard:

```
<business_vertical>.<environment_tier>.<scope>.<data_grouping>.<data_description>.<integrity_level>[.<origin>][.<publisher_identifier>].<dorc_environment>
```

e.g. `tr.dv.gbl.traveler.trade-events.il2.dev01`. Optional segments (`origin`, `publisher_identifier`) are omitted when left empty. The DOrc environment the topic is linked to is always the final segment — the tier says *which class* of environment, the DOrc environment says *which instance*, matching existing DOrc-linked topics such as `tr.dv.gbl.trades.il2.tradeevents.gma.dev01`. Conventions follow the Trading Core `Traveler.Topics.Terraform` repository.

## Target Kafka instances (SEFE BYOC)

Topics are created on the SEFE **traveler** Kafka instances, which run as Aiven BYOC services on Azure uksouth (custom clouds `custom-sefe-nprod-workload-azure-uksouth` / `custom-sefe-prod-workload-azure-uksouth`). `service_name` is restricted to them; leave it empty and the module selects from `environment_tier`:

| `environment_tier` | Instance |
|---|---|
| `dv` | `traveler-unstable-dev` |
| `ut`, `qa`, `pp` | `traveler-non-prod` |
| `pr` | `traveler-production` |

The Kafka service itself is referenced, never managed.

## Access control (ACLs)

The traveler clusters run with **ACL enforcement on** — creating a topic does not make it usable; a client can only produce/consume once an ACL entry grants its service user access. Do **not** disable cluster ACLs to work around this. Two complementary mechanisms:

1. **Platform-managed prefix ACLs (baseline).** The platform team maintains per-application wildcard grants out-of-band, so any topic created under an agreed prefix is immediately usable with zero per-topic work, e.g.:

   ```hcl
   resource "aiven_kafka_acl" "traveler_app_baseline" {
     project      = "trading-traveler"
     service_name = "traveler-non-prod"
     topic        = "tr.*.gbl.traveler.*"
     username     = "traveler-app"
     permission   = "readwrite"
   }
   ```

   The predictable topic naming (tier + final `dorc_environment` segment) is what makes these prefixes safe to scope.

2. **Per-topic grants (`acl_entries`).** For access the baseline doesn't cover, pass comma-separated `username:permission` pairs and the module creates exact-topic `aiven_kafka_acl` entries alongside the topic, e.g. `acl_entries = "traveler-app:readwrite,analytics-*:read"`. String-encoded so the DOrc catalog (simple parameter types only) can drive it.

## Authentication

The Aiven provider authenticates with an API token. Per the module contract the module declares no provider block; supply the token via the `AIVEN_TOKEN` environment variable on the runner, or per DOrc environment with the secure `TerraformAivenApiToken` environment property (injected as `AIVEN_TOKEN` on the terraform process only).

## Inputs

| Name | Type | Required | Description |
|---|---|:-:|---|
| `project` | string | no (`trading-traveler`) | Aiven console project. |
| `service_name` | string | no (``) | One of the traveler instances; empty = derived from `environment_tier`. |
| `business_vertical` | string | yes | Two-character vertical code (e.g. `tr`). |
| `environment_tier` | string | yes | One of `dv`, `ut`, `qa`, `pp`, `pr`. |
| `dorc_environment` | string | yes | DOrc environment instance (e.g. `dev01`, `ut02`); normalised and appended as the final segment. |
| `scope` | string | yes | One of `gbl`, `lcl`, `usr`, `tst`. |
| `data_grouping` | string | yes | Logical grouping segment (app/domain). |
| `data_description` | string | yes | Data description segment (entity/message type). |
| `integrity_level` | string | yes | One of `il0`–`il3`. |
| `origin` | string | no (``) | Optional 3-char origin system code. |
| `publisher_identifier` | string | no (``) | Optional publisher segment. |
| `partitions` | number | no (`3`) | Can grow, never shrink. |
| `replication` | number | no (`2`) | Aiven minimum is 2. |
| `cleanup_policy` | string | no (`delete`) | `delete`, `compact`, or `compact,delete`. |
| `min_insync_replicas` | number | no (`2`) | Min ISR for acknowledged writes. |
| `retention_ms` | number | no (`604800000`) | 7 days; `-1` = unlimited. |
| `retention_bytes` | number | no (`-1`) | `-1` = unlimited. |
| `termination_protection` | bool | no (`true`) | Client-side delete protection. |
| `acl_entries` | string | no (``) | Comma-separated `username:permission` ACL grants on this topic; see Access control. |

## Outputs

`topic_id`, `topic_name`, `project`, `service_name`, `partitions`, `acl_ids`.

## Secret handling

This module takes no secret inputs and outputs no credentials.

## Example

See `examples/basic/`.

## Versioning

Released as Git tag `stock-modules/kafka-topic/v<X.Y.Z>`.
