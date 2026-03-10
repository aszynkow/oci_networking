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

variable "nsg_web_id" {
  description = "OCID of NSG-Web (output from Chapter 04)"
  type        = string
}

variable "nsg_app_id" {
  description = "OCID of NSG-App (output from Chapter 04)"
  type        = string
}

variable "web_vm_ip" {
  description = "Private IP of the web-tier VM in subnet-public (e.g. 10.0.1.10)"
  type        = string
  default     = "10.0.1.10"
}

variable "app_vm_ip" {
  description = "Private IP of the app-tier VM in subnet-private (e.g. 10.0.2.10)"
  type        = string
  default     = "10.0.2.10"
}
