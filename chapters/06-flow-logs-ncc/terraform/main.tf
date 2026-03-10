# -----------------------------------------------------------------------------
# Chapter 06 — VCN Flow Logs & Network Command Center
# Creates:
#   - Log Group: lab-network-logs
#   - Flow Log:  flow-log-subnet-public (enabled on subnet-public)
#
# OCI Logging resources use the oci_logging_* provider types.
# Flow logs are enabled as a "service log" via oci_logging_log.
#
# Depends on: VCN (Ch01), subnet-public (Ch01)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Log Group
# A log group is a logical container for related logs.
# All lab flow logs are stored here.
# -----------------------------------------------------------------------------
resource "oci_logging_log_group" "lab_network_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "lab-network-logs"
  description    = "VCN flow logs for OCI networking lab"

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "06"
  }
}

# -----------------------------------------------------------------------------
# Flow Log — subnet-public
# Captures all ACCEPT and REJECT traffic metadata on subnet-public.
# Uses the OCI VCN flow log service category.
# -----------------------------------------------------------------------------
resource "oci_logging_log" "flow_log_public_subnet" {
  display_name = "flow-log-subnet-public"
  log_group_id = oci_logging_log_group.lab_network_logs.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"                      # Captures both ACCEPT and REJECT
      resource    = var.public_subnet_id       # The subnet to enable flow logs on
      service     = "flowlogs"                 # OCI service identifier for VCN flow logs
      source_type = "OCISERVICE"
    }

    compartment_id = var.compartment_ocid
  }

  retention_duration = var.log_retention_days

  is_enabled = true

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "06"
    "subnet"  = "public"
  }
}

# -----------------------------------------------------------------------------
# (Optional) Flow Log — subnet-private
# Uncomment to also enable flow logs on the private subnet.
# -----------------------------------------------------------------------------
# resource "oci_logging_log" "flow_log_private_subnet" {
#   display_name = "flow-log-subnet-private"
#   log_group_id = oci_logging_log_group.lab_network_logs.id
#   log_type     = "SERVICE"
#
#   configuration {
#     source {
#       category    = "all"
#       resource    = var.private_subnet_id
#       service     = "flowlogs"
#       source_type = "OCISERVICE"
#     }
#     compartment_id = var.compartment_ocid
#   }
#
#   retention_duration = var.log_retention_days
#   is_enabled         = true
# }
