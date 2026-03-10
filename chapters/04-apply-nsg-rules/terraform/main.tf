# -----------------------------------------------------------------------------
# Chapter 04 — Apply NSG Rules
# Creates: NSG-Web, NSG-App with micro-segmentation rules
# NSG-App ingress rule references NSG-Web as source (not a CIDR)
# Depends on: lab-vcn (Chapter 01)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# NSG-Web — Web tier security group
# Applied to: VNICs in subnet-public (web-facing instances)
# Rules: Allow HTTPS (443) + HTTP (80) inbound, all outbound
# -----------------------------------------------------------------------------
resource "oci_core_network_security_group" "nsg_web" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "NSG-Web"

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "04"
    "tier"    = "web"
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_web_ingress_https" {
  network_security_group_id = oci_core_network_security_group.nsg_web.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }

  description = "Allow HTTPS from internet"
}

resource "oci_core_network_security_group_security_rule" "nsg_web_ingress_http" {
  network_security_group_id = oci_core_network_security_group.nsg_web.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }

  description = "Allow HTTP from internet"
}

resource "oci_core_network_security_group_security_rule" "nsg_web_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_web.id
  direction                 = "EGRESS"
  protocol                  = "all"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless        = false

  description = "Allow all outbound traffic"
}

# -----------------------------------------------------------------------------
# NSG-App — Application tier security group
# Applied to: VNICs in subnet-private (app instances)
# Rules:
#   - Ingress port 8080 from NSG-Web only (NSG reference, not CIDR)
#   - Ingress SSH (22) from VCN CIDR for management
#   - All outbound
# -----------------------------------------------------------------------------
resource "oci_core_network_security_group" "nsg_app" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "NSG-App"

  freeform_tags = {
    "lab"     = "oci-networking"
    "chapter" = "04"
    "tier"    = "app"
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_app_ingress_8080_from_web" {
  network_security_group_id = oci_core_network_security_group.nsg_app.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP

  # Source is NSG-Web OCID — micro-segmentation pattern unique to NSGs
  source      = oci_core_network_security_group.nsg_web.id
  source_type = "NETWORK_SECURITY_GROUP"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }

  description = "Allow app traffic from Web tier NSG only"
}

resource "oci_core_network_security_group_security_rule" "nsg_app_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.nsg_app.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP

  source      = "10.0.0.0/16"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  description = "Allow SSH from within VCN only"
}

resource "oci_core_network_security_group_security_rule" "nsg_app_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_app.id
  direction                 = "EGRESS"
  protocol                  = "all"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless        = false

  description = "Allow all outbound traffic"
}
