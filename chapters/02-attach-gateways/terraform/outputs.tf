output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.lab_igw.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.lab_nat_gw.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address assigned to the NAT Gateway"
  value       = oci_core_nat_gateway.lab_nat_gw.nat_ip
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = oci_core_service_gateway.lab_sgw.id
}

output "oracle_services_id" {
  description = "OCID of the Oracle Services bundle used by the Service Gateway"
  value       = data.oci_core_services.all_services.services[0].id
}
