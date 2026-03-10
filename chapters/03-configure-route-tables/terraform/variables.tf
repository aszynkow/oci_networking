variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the OCI user running Terraform"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the OCI API key"
  type        = string
}

variable "private_key_path" {
  description = "Local path to the OCI API private key (.pem file)"
  type        = string
}

variable "region" {
  description = "OCI region identifier (e.g. us-ashburn-1)"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCID of the target compartment"
  type        = string
}

variable "vcn_id" {
  description = "OCID of lab-vcn (output from Chapter 01)"
  type        = string
}

variable "public_subnet_id" {
  description = "OCID of subnet-public (output from Chapter 01)"
  type        = string
}

variable "private_subnet_id" {
  description = "OCID of subnet-private (output from Chapter 01)"
  type        = string
}

variable "internet_gateway_id" {
  description = "OCID of lab-igw (output from Chapter 02)"
  type        = string
}

variable "nat_gateway_id" {
  description = "OCID of lab-nat-gw (output from Chapter 02)"
  type        = string
}

variable "service_gateway_id" {
  description = "OCID of lab-sgw (output from Chapter 02)"
  type        = string
}

variable "oracle_services_id" {
  description = "OCID of Oracle Services bundle (output from Chapter 02)"
  type        = string
}
