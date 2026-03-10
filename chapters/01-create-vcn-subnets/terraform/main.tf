# -----------------------------------------------------------------------------
# Chapter 01 — Create VCN & Subnets
# Creates: lab-vcn, subnet-public, subnet-private
# -----------------------------------------------------------------------------

resource "oci_core_vcn" "lab_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "lab-vcn"
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = "labvcn"

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "01"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.lab_vcn.id
  display_name      = "subnet-public"
  cidr_block        = var.public_subnet_cidr
  dns_label         = "subnetpub"

  # Public subnet — resources may have public IPs
  prohibit_public_ip_on_vnic = false

  # Route table and security list wired up in later chapters;
  # defaults are used here so the subnet is immediately available.
  route_table_id    = oci_core_vcn.lab_vcn.default_route_table_id
  security_list_ids = [oci_core_vcn.lab_vcn.default_security_list_id]

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "01"
    "tier"    = "public"
  }
}

resource "oci_core_subnet" "private" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.lab_vcn.id
  display_name      = "subnet-private"
  cidr_block        = var.private_subnet_cidr
  dns_label         = "subnetprv"

  # Private subnet — no public IPs on VNICs
  prohibit_public_ip_on_vnic = true

  route_table_id    = oci_core_vcn.lab_vcn.default_route_table_id
  security_list_ids = [oci_core_vcn.lab_vcn.default_security_list_id]

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "01"
    "tier"    = "private"
  }
}
