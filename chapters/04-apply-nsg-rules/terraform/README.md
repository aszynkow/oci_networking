# Terraform — Chapter 04: Apply NSG Rules

This module creates two Network Security Groups with micro-segmentation rules:

| NSG | Ingress Rules | Egress |
|---|---|---|
| `NSG-Web` | TCP 443 + TCP 80 from `0.0.0.0/0` | All |
| `NSG-App` | TCP 8080 from **NSG-Web** (NSG reference) + SSH from VCN | All |

The key pattern here is that `NSG-App`'s port-8080 rule sources from `NSG-Web` itself — not a CIDR — enabling precise tier-to-tier micro-segmentation.

**Depends on:** Chapter 01 (`vcn_id` only — NSGs live at VCN scope)

---

## Prerequisites

- Terraform >= 1.3.0
- OCI API key configured
- Chapter 01 applied — `lab-vcn` must exist
- IAM permission: `manage network-security-groups` in the target compartment

---

## Steps to Run

### 1 — Get the VCN OCID from Chapter 01

```bash
cd ../01-create-vcn-subnets/terraform
terraform output -raw vcn_id
```

### 2 — Navigate to this chapter

```bash
cd ../../04-apply-nsg-rules/terraform
```

### 3 — Create your variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaa..."
user_ocid        = "ocid1.user.oc1..aaaa..."
fingerprint      = "aa:bb:cc:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.compartment.oc1..aaaa..."
vcn_id           = "ocid1.vcn.oc1.iad.aaaa..."
```

### 4 — Initialise

```bash
terraform init
```

### 5 — Plan

```bash
terraform plan
```

Expected: **8 resources to add**:
- `oci_core_network_security_group.nsg_web`
- `oci_core_network_security_group.nsg_app`
- 3 × `oci_core_network_security_group_security_rule` for NSG-Web
- 3 × `oci_core_network_security_group_security_rule` for NSG-App

Notice in the plan that the NSG-App ingress rule for port 8080 references NSG-Web's OCID as its source — Terraform resolves this automatically because both resources are in the same plan.

### 6 — Apply

```bash
terraform apply
```

Expected output:
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
nsg_web_id = "ocid1.networksecuritygroup.oc1.iad.aaaa..."
nsg_app_id = "ocid1.networksecuritygroup.oc1.iad.aaaa..."
```

### 7 — Save NSG OCIDs for attaching to compute instances

```bash
export TF_NSG_WEB_ID=$(terraform output -raw nsg_web_id)
export TF_NSG_APP_ID=$(terraform output -raw nsg_app_id)
```

Use these OCIDs when launching compute instances to attach them to the correct NSG:

```hcl
# Example: compute instance in terraform using NSG-Web
resource "oci_core_instance" "web_vm" {
  ...
  create_vnic_details {
    subnet_id              = var.public_subnet_id
    nsg_ids                = [var.nsg_web_id]   # <-- attach NSG-Web
    assign_public_ip       = true
  }
}
```

---

## Key Terraform Pattern — NSG-to-NSG Rule

The NSG reference in the ingress rule for NSG-App:

```hcl
resource "oci_core_network_security_group_security_rule" "nsg_app_ingress_8080_from_web" {
  source      = oci_core_network_security_group.nsg_web.id   # NSG OCID as source
  source_type = "NETWORK_SECURITY_GROUP"                     # Not CIDR_BLOCK
  ...
}
```

When `source_type = "NETWORK_SECURITY_GROUP"`, the `source` field must be the **OCID of another NSG in the same VCN**. This creates a dependency: Terraform will create `nsg_web` before `nsg_app`'s rules because the rule references `nsg_web.id`.

## Protocol Numbers

OCI NSG rules use IANA protocol numbers, not names:

| Protocol | Number |
|---|---|
| TCP | `"6"` |
| UDP | `"17"` |
| ICMP | `"1"` |
| All | `"all"` |

---

## Verify in OCI Console

1. **Networking** → **Virtual Cloud Networks** → `lab-vcn` → **Network Security Groups**
2. Click `NSG-Web` → confirm 3 rules: ingress 443, ingress 80, egress all
3. Click `NSG-App` → confirm 3 rules: ingress 8080 (source: NSG-Web), ingress 22, egress all
4. On the port-8080 rule, confirm **Source** column shows `NSG-Web` (not a CIDR)

---

## Destroy Resources

```bash
terraform destroy
```

> NSGs can be destroyed independently of other chapters since they are not referenced by route tables or gateways. However, if compute instances are attached to these NSGs, Terraform will fail — detach instances first.

---

## Files in This Directory

| File | Purpose |
|---|---|
| `provider.tf` | OCI provider configuration |
| `variables.tf` | Input variable declarations |
| `main.tf` | NSG resources + 6 security rules |
| `outputs.tf` | NSG OCIDs |
| `terraform.tfvars.example` | Template — copy to `terraform.tfvars` |

---

## Next Chapter

➡️ [Chapter 05 — Run Path Analyzer](../../05-run-path-analyzer/terraform/README.md)
