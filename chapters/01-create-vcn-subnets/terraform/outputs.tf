output "vcn_id" {
  description = "OCID of the created VCN"
  value       = oci_core_vcn.lab_vcn.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.lab_vcn.cidr_blocks[0]
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private.id
}

output "default_route_table_id" {
  description = "OCID of the VCN default route table"
  value       = oci_core_vcn.lab_vcn.default_route_table_id
}

output "default_security_list_id" {
  description = "OCID of the VCN default security list"
  value       = oci_core_vcn.lab_vcn.default_security_list_id
}
