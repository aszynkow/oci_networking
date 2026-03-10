# -----------------------------------------------------------------------------
# Chapter 05 — Path Analyzer
# Creates three saved path analysis configurations:
#   1. internet-to-web-443    → should be REACHABLE
#   2. internet-to-app-8080   → should be NOT REACHABLE (no internet route)
#   3. web-to-app-8080        → should be REACHABLE (NSG-Web is source)
#
# These are persistent, reusable analyses — re-run them any time to verify
# the network posture hasn't drifted.
#
# Depends on: VCN (Ch01), subnets (Ch01), NSGs (Ch04)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Test 1 — Internet → Web VM on port 443 (expected: REACHABLE)
# -----------------------------------------------------------------------------
resource "oci_network_path_analyzer_path_analysis_work_request_result" "internet_to_web_443" {
  # Note: oci_vn_monitoring_path_analyzer_test is the resource type used
  # for saved/persistent analyses in the OCI provider.
}

# The OCI Terraform provider uses oci_vn_monitoring_path_analyzer_test
# for creating reusable saved Path Analyzer tests.

resource "oci_vn_monitoring_path_analyzer_test" "internet_to_web_443" {
  compartment_id = var.compartment_ocid
  display_name   = "internet-to-web-443"
  protocol       = 6 # TCP

  source_endpoint {
    type = "CIDR_ADDRESS"
    address = "8.8.8.8/32"
  }

  destination_endpoint {
    type      = "IP_ADDRESS"
    address   = var.web_vm_ip
  }

  protocol_parameters {
    type              = "TCP"
    destination_port  = 443
    source_port       = 1024
  }

  freeform_tags = {
    "lab"      = "oci-networking"
    "chapter"  = "05"
    "expected" = "reachable"
  }
}

# -----------------------------------------------------------------------------
# Test 2 — Internet → App VM on port 8080 (expected: NOT REACHABLE)
# Private subnet has no inbound internet route and NSG-App
# only allows port 8080 from NSG-Web, not from internet CIDRs.
# -----------------------------------------------------------------------------
resource "oci_vn_monitoring_path_analyzer_test" "internet_to_app_8080" {
  compartment_id = var.compartment_ocid
  display_name   = "internet-to-app-8080-blocked"
  protocol       = 6 # TCP

  source_endpoint {
    type    = "CIDR_ADDRESS"
    address = "8.8.8.8/32"
  }

  destination_endpoint {
    type    = "IP_ADDRESS"
    address = var.app_vm_ip
  }

  protocol_parameters {
    type             = "TCP"
    destination_port = 8080
    source_port      = 1024
  }

  freeform_tags = {
    "lab"      = "oci-networking"
    "chapter"  = "05"
    "expected" = "not-reachable"
  }
}

# -----------------------------------------------------------------------------
# Test 3 — Web VM → App VM on port 8080 (expected: REACHABLE)
# VCN-internal traffic; NSG-App allows port 8080 from NSG-Web source.
# -----------------------------------------------------------------------------
resource "oci_vn_monitoring_path_analyzer_test" "web_to_app_8080" {
  compartment_id = var.compartment_ocid
  display_name   = "web-to-app-8080-allowed"
  protocol       = 6 # TCP

  source_endpoint {
    type      = "SUBNET"
    subnet_id = var.public_subnet_id
    address   = var.web_vm_ip
  }

  destination_endpoint {
    type      = "SUBNET"
    subnet_id = var.private_subnet_id
    address   = var.app_vm_ip
  }

  protocol_parameters {
    type             = "TCP"
    destination_port = 8080
    source_port      = 1024
  }

  freeform_tags = {
    "lab"      = "oci-networking"
    "chapter"  = "05"
    "expected" = "reachable"
  }
}
