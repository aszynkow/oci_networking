# -----------------------------------------------------------------------------
# Chapter 02 — Attach Gateways
# Creates: Internet Gateway, NAT Gateway, Service Gateway
# Depends on: lab-vcn (Chapter 01)
# -----------------------------------------------------------------------------

# Fetch the VCN to validate it exists and retrieve metadata
data "oci_core_vcn" "lab_vcn" {
  vcn_id = var.vcn_id
}

# Fetch available Oracle Services in this region for the Service Gateway
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway
# Allows bidirectional internet traffic for resources in the public subnet.
# Hard limit: 1 per VCN.
# -----------------------------------------------------------------------------
resource "oci_core_internet_gateway" "lab_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "lab-igw"
  enabled        = true

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "02"
  }
}

# -----------------------------------------------------------------------------
# NAT Gateway
# Allows outbound-only internet traffic for resources in the private subnet.
# Hard limit: 1 per VCN.
# -----------------------------------------------------------------------------
resource "oci_core_nat_gateway" "lab_nat_gw" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "lab-nat-gw"

  # block_traffic = false means NAT GW is active (set true to temporarily disable)
  block_traffic = false

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "02"
  }
}

# -----------------------------------------------------------------------------
# Service Gateway
# Enables private access to Oracle Services (Object Storage, OCI APIs)
# without traversing the public internet.
# Hard limit: 1 per VCN.
# -----------------------------------------------------------------------------
resource "oci_core_service_gateway" "lab_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "lab-sgw"

  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "02"
  }
}
