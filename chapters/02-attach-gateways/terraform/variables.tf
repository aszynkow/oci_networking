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
