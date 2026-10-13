# Topic name per the SEFE Kafka messaging standard; optional trailing
# segments are dropped when empty. The DOrc environment the topic is linked
# to is always the final segment, matching existing DOrc-linked topics
# (e.g. tr.dv.gbl.trades.il2.tradeevents.gma.dev01).
locals {
  dorc_environment_segment = replace(lower(var.dorc_environment), "/[^a-z0-9_-]/", "")

  topic_name = join(".", compact([
    var.business_vertical,
    var.environment_tier,
    var.scope,
    var.data_grouping,
    var.data_description,
    var.integrity_level,
    var.origin,
    var.publisher_identifier,
    local.dorc_environment_segment,
  ]))

  # SEFE traveler Kafka instances (Aiven BYOC on Azure uksouth). When no
  # instance is named explicitly, the environment tier picks it.
  service_by_tier = {
    dv = "traveler-unstable-dev"
    ut = "traveler-non-prod"
    qa = "traveler-non-prod"
    pp = "traveler-non-prod"
    pr = "traveler-production"
  }
  service_name = var.service_name != "" ? var.service_name : local.service_by_tier[var.environment_tier]

  # "user:permission,user:permission" -> list of {username, permission};
  # string-encoded so the DOrc catalog (simple parameter types only) can
  # drive it.
  acl_entries = [for e in compact(split(",", replace(var.acl_entries, " ", ""))) : {
    username   = split(":", e)[0]
    permission = split(":", e)[1]
  }]
}

resource "aiven_kafka_topic" "this" {
  project                = var.project
  service_name           = local.service_name
  topic_name             = local.topic_name
  partitions             = var.partitions
  replication            = var.replication
  termination_protection = var.termination_protection

  config {
    cleanup_policy      = var.cleanup_policy
    min_insync_replicas = var.min_insync_replicas
    retention_bytes     = var.retention_bytes
    retention_ms        = var.retention_ms
  }
}

# Per-topic grants so the topic is usable with cluster ACL enforcement on.
# Baseline access should come from platform-managed prefix ACLs (see
# README); these entries cover topic-specific needs only.
resource "aiven_kafka_acl" "this" {
  for_each = { for a in local.acl_entries : "${a.username}:${a.permission}" => a }

  project      = var.project
  service_name = local.service_name
  topic        = local.topic_name
  username     = each.value.username
  permission   = each.value.permission
}
