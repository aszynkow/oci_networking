# Terraform — Chapter 03: Configure Route Tables

This module creates two route tables and associates them with their subnets:

| Route Table | Subnet | Rules |
|---|---|---|
| `rt-public` | `subnet-public` | `0.0.0.0/0` → `lab-igw` |
| `rt-private` | `subnet-private` | `0.0.0.0/0` → `lab-nat-gw` + All Services → `lab-sgw` |

**Depends on:** Chapter 01 (VCN + subnets), Chapter 02 (gateways)

---

## Prerequisites

- Terraform >= 1.3.0
- OCI API key configured
- Chapter 01 and Chapter 02 applied successfully

---

## Steps to Run

### 1 — Collect outputs from previous chapters

```bash
# From Chapter 01
cd ../01-create-vcn-subnets/terraform
terraform output

# From Chapter 02
cd ../../02-attach-gateways/terraform
terraform output
```

### 2 — Navigate to this chapter

```bash
cd ../../03-configure-route-tables/terraform
```

### 3 — Create your variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Populate all values from previous chapter outputs:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaa..."
user_ocid        = "ocid1.user.oc1..aaaa..."
fingerprint      = "aa:bb:cc:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.compartment.oc1..aaaa..."

# Chapter 01 outputs
vcn_id            = "ocid1.vcn.oc1.iad.aaaa..."
public_subnet_id  = "ocid1.subnet.oc1.iad.aaaa..."
private_subnet_id = "ocid1.subnet.oc1.iad.aaaa..."

# Chapter 02 outputs
internet_gateway_id = "ocid1.internetgateway.oc1.iad.aaaa..."
nat_gateway_id      = "ocid1.natgateway.oc1.iad.aaaa..."
service_gateway_id  = "ocid1.servicegateway.oc1.iad.aaaa..."
oracle_services_id  = "ocid1.service.oc1..aaaa..."
```

### 4 — Initialise

```bash
terraform init
```

### 5 — Plan

```bash
terraform plan
```

Expected: **4 resources to add**:
- `oci_core_route_table.rt_public`
- `oci_core_route_table.rt_private`
- `oci_core_route_table_attachment.public_subnet_rt`
- `oci_core_route_table_attachment.private_subnet_rt`

### 6 — Apply

```bash
terraform apply
```

Expected output:
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:
rt_public_id  = "ocid1.routetable.oc1.iad.aaaa..."
rt_private_id = "ocid1.routetable.oc1.iad.aaaa..."
```

---

## Key Terraform Note — Service Gateway Route Rule

The Service Gateway route rule uses a non-obvious syntax:

```hcl
route_rules {
  destination       = var.oracle_services_id   # OCID, not a CIDR string
  destination_type  = "SERVICE_CIDR_BLOCK"     # Not "CIDR_BLOCK"
  network_entity_id = var.service_gateway_id
}
```

This is different from all other route rules. The `destination` field for a Service Gateway rule must be the **Oracle Services bundle OCID** (from `data.oci_core_services`), and `destination_type` must be `SERVICE_CIDR_BLOCK`. Using `CIDR_BLOCK` here will cause a plan error.

---

## Verify in OCI Console

1. **Networking** → **Virtual Cloud Networks** → `lab-vcn` → **Route Tables**
2. Confirm `rt-public` shows: `0.0.0.0/0 → lab-igw`
3. Confirm `rt-private` shows two rules: NAT GW default + Services rule
4. Click `subnet-public` → confirm Route Table = `rt-public`
5. Click `subnet-private` → confirm Route Table = `rt-private`

---

## Destroy Resources

```bash
terraform destroy
```

> Destroy Chapter 03 before Chapter 02, as route rules reference gateway OCIDs.

---

## Files in This Directory

| File | Purpose |
|---|---|
| `provider.tf` | OCI provider configuration |
| `variables.tf` | Input variable declarations |
| `main.tf` | Route tables + subnet associations |
| `outputs.tf` | Route table OCIDs |
| `terraform.tfvars.example` | Template — copy to `terraform.tfvars` |

---

## Next Chapter

➡️ [Chapter 04 — Apply NSG Rules](../../04-apply-nsg-rules/terraform/README.md)
