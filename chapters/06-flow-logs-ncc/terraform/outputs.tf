output "log_group_id" {
  description = "OCID of the lab-network-logs log group"
  value       = oci_logging_log_group.lab_network_logs.id
}

output "flow_log_id" {
  description = "OCID of the flow-log-subnet-public log"
  value       = oci_logging_log.flow_log_public_subnet.id
}

output "console_url_log_explorer" {
  description = "Direct link to Log Explorer for this log group"
  value       = "https://cloud.oracle.com/logging/log-explorer?region=${var.region}"
}

output "console_url_ncc" {
  description = "Direct link to Network Command Center"
  value       = "https://cloud.oracle.com/networking/network-command-center?region=${var.region}"
}
