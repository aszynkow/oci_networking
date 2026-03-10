# -----------------------------------------------------------------------------
# Chapter 03 — Configure Route Tables
# Creates: rt-public, rt-private and associates them with subnets
# Depends on: lab-vcn (Ch01), lab-igw, lab-nat-gw, lab-sgw (Ch02)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Public Route Table
# One rule: default route 0.0.0.0/0 → Internet Gateway
# -----------------------------------------------------------------------------
resource "oci_core_route_table" "rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.internet_gateway_id
    description       = "Default route to internet via IGW"
  }

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "03"
    "tier"    = "public"
  }
}

# -----------------------------------------------------------------------------
# Private Route Table
# Two rules:
#   1. Default outbound route → NAT Gateway
#   2. Oracle Services route → Service Gateway (no internet hop)
# -----------------------------------------------------------------------------
resource "oci_core_route_table" "rt_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.nat_gateway_id
    description       = "Default outbound route via NAT GW"
  }

  route_rules {
    # Service Gateway routes use destination_type = SERVICE_CIDR_BLOCK
    # and reference the Oracle Services bundle OCID, not a CIDR string.
    destination       = var.oracle_services_id
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.service_gateway_id
    description       = "Oracle Services via Service GW (no internet hop)"
  }

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "03"
    "tier"    = "private"
  }
}

# -----------------------------------------------------------------------------
# Associate rt-public with subnet-public
# oci_core_route_table_attachment is the explicit association resource.
# -----------------------------------------------------------------------------
resource "oci_core_route_table_attachment" "public_subnet_rt" {
  subnet_id      = var.public_subnet_id
  route_table_id = oci_core_route_table.rt_public.id
}

# -----------------------------------------------------------------------------
# Associate rt-private with subnet-private
# -----------------------------------------------------------------------------
resource "oci_core_route_table_attachment" "private_subnet_rt" {
  subnet_id      = var.private_subnet_id
  route_table_id = oci_core_route_table.rt_private.id
}
