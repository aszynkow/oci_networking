output "rt_public_id" {
  description = "OCID of the public route table"
  value       = oci_core_route_table.rt_public.id
}

output "rt_private_id" {
  description = "OCID of the private route table"
  value       = oci_core_route_table.rt_private.id
}
