# Terraform — Chapter 02: Attach Gateways

This module provisions the three OCI network gateways:
- **`lab-igw`** — Internet Gateway (bidirectional internet for public subnet)
- **`lab-nat-gw`** — NAT Gateway (outbound-only internet for private subnet)
- **`lab-sgw`** — Service Gateway (private access to Oracle Services)

**Depends on:** Chapter 01 (`vcn_id` output)

---

## Prerequisites

- Terraform >= 1.3.0 installed ([install guide](https://developer.hashicorp.com/terraform/install))
- OCI API key configured (`~/.oci/config`)
- Chapter 01 applied — `lab-vcn` must exist
- IAM permission: `manage virtual-network-family` in the target compartment

---

## Steps to Run

### 1 — Get the VCN OCID from Chapter 01

```bash
cd ../01-create-vcn-subnets/terraform
terraform output -raw vcn_id
# ocid1.vcn.oc1.iad.aaaa...
```

### 2 — Navigate to this chapter's terraform directory

```bash
cd ../../02-attach-gateways/terraform
```

### 3 — Create your variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` — paste in the `vcn_id` from Step 1:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaa..."
user_ocid        = "ocid1.user.oc1..aaaa..."
fingerprint      = "aa:bb:cc:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.compartment.oc1..aaaa..."
vcn_id           = "ocid1.vcn.oc1.iad.aaaa..."   # <-- from Chapter 01
```

### 4 — Initialise Terraform

```bash
terraform init
```

### 5 — Preview the plan

```bash
terraform plan
```

You should see **3 resources to add**:
- `oci_core_internet_gateway.lab_igw`
- `oci_core_nat_gateway.lab_nat_gw`
- `oci_core_service_gateway.lab_sgw`

Plus 1 data source read:
- `data.oci_core_services.all_services` — queries the current region for Oracle Service bundles

### 6 — Apply

```bash
terraform apply
```

Type `yes` when prompted.

Expected output:
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
internet_gateway_id  = "ocid1.internetgateway.oc1.iad.aaaa..."
nat_gateway_id       = "ocid1.natgateway.oc1.iad.aaaa..."
nat_gateway_public_ip = "129.x.x.x"
service_gateway_id   = "ocid1.servicegateway.oc1.iad.aaaa..."
```

### 7 — Save outputs for Chapter 03

```bash
terraform output -json > ../tf-outputs.json

# Or export individually
export TF_IGW_ID=$(terraform output -raw internet_gateway_id)
export TF_NAT_ID=$(terraform output -raw nat_gateway_id)
export TF_SGW_ID=$(terraform output -raw service_gateway_id)
export TF_ORACLE_SVC_ID=$(terraform output -raw oracle_services_id)
```

---

## What the Data Source Does

```hcl
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
```

This queries OCI for the region-specific Oracle Services bundle OCID (e.g. `All IAD Services in Oracle Services Network`). The bundle OCID differs per region, so using a data source ensures the correct one is used without hardcoding.

---

## Verify in OCI Console

1. Navigate to **Networking** → **Virtual Cloud Networks** → `lab-vcn`
2. Check **Internet Gateways** — `lab-igw` should appear, Enabled: Yes
3. Check **NAT Gateways** — `lab-nat-gw` should have a public IP
4. Check **Service Gateways** — `lab-sgw` should show "All Services"

> ⚠️ Gateways exist but traffic does **not** flow through them yet. Route rules are wired in Chapter 03.

---

## Disabling the NAT Gateway (without destroying)

To temporarily block outbound internet from private subnet without destroying the resource:

```bash
# Edit terraform.tfvars or override inline
terraform apply -var="block_nat_traffic=true"
```

Or update `main.tf`:
```hcl
resource "oci_core_nat_gateway" "lab_nat_gw" {
  block_traffic = true   # temporarily disables the gateway
  ...
}
```

---

## Destroy Resources

```bash
terraform destroy
```

> Destroy Chapter 03 resources **before** destroying Chapter 02, as route table rules reference these gateway OCIDs.

---

## Files in This Directory

| File | Purpose |
|---|---|
| `provider.tf` | OCI provider configuration |
| `variables.tf` | Input variable declarations |
| `main.tf` | IGW, NAT GW, Service GW resources + services data source |
| `outputs.tf` | Gateway OCIDs and NAT public IP |
| `terraform.tfvars.example` | Template — copy to `terraform.tfvars` |

---

## Next Chapter

➡️ [Chapter 03 — Configure Route Tables](../../03-configure-route-tables/terraform/README.md)
