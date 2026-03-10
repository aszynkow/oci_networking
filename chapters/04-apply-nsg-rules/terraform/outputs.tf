output "nsg_web_id" {
  description = "OCID of NSG-Web"
  value       = oci_core_network_security_group.nsg_web.id
}

output "nsg_app_id" {
  description = "OCID of NSG-App"
  value       = oci_core_network_security_group.nsg_app.id
}
