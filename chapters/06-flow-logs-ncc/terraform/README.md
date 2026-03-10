# Terraform — Chapter 06: VCN Flow Logs & Network Command Center

This module enables traffic visibility by provisioning:

- **`lab-network-logs`** — OCI Log Group (container for all lab logs)
- **`flow-log-subnet-public`** — VCN Flow Log on `subnet-public` (captures all ACCEPT + REJECT flows)

Network Command Center requires no Terraform provisioning — it is a built-in OCI console feature that automatically discovers your network topology.

**Depends on:** Chapter 01 (`vcn_id`, `public_subnet_id`)

---

## Prerequisites

- Terraform >= 1.3.0
- OCI provider >= 5.0.0
- Chapter 01 applied — `subnet-public` must exist
- IAM permissions:
  - `manage log-groups` in the target compartment
  - `manage logs` in the target compartment

---

## Steps to Run

### 1 — Get outputs from Chapter 01

```bash
cd ../01-create-vcn-subnets/terraform
terraform output -raw vcn_id
terraform output -raw public_subnet_id
```

### 2 — Navigate to this chapter

```bash
cd ../../06-flow-logs-ncc/terraform
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

vcn_id           = "ocid1.vcn.oc1.iad.aaaa..."   # Chapter 01
public_subnet_id = "ocid1.subnet.oc1.iad.aaaa..."  # Chapter 01
```

### 4 — Initialise

```bash
terraform init
```

### 5 — Plan

```bash
terraform plan
```

Expected: **2 resources to add**:
- `oci_logging_log_group.lab_network_logs`
- `oci_logging_log.flow_log_public_subnet`

### 6 — Apply

```bash
terraform apply
```

Expected output:
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
log_group_id              = "ocid1.loggroup.oc1.iad.aaaa..."
flow_log_id               = "ocid1.log.oc1.iad.aaaa..."
console_url_log_explorer  = "https://cloud.oracle.com/logging/log-explorer?region=us-ashburn-1"
console_url_ncc           = "https://cloud.oracle.com/networking/network-command-center?region=us-ashburn-1"
```

---

## Verify the Flow Log is Active

After apply, open the console and confirm:

```bash
# Open Log Explorer directly
terraform output -raw console_url_log_explorer
```

**In the Console:**
1. Navigate to **Observability & Management** → **Logging** → **Logs**
2. Confirm `flow-log-subnet-public` shows **State: Active**
3. If state is **Inactive**, check IAM permissions for the Logging service

---

## Query Flow Logs via OCI CLI

After traffic has been generated through `subnet-public`, you can search logs from the CLI:

```bash
LOG_ID=$(terraform output -raw flow_log_id)
LOG_GROUP_ID=$(terraform output -raw log_group_id)

# Search for REJECT records in the last 30 minutes
oci logging-search search-logs \
  --search-query "search \"${LOG_GROUP_ID}/${LOG_ID}\" | where data.action = 'REJECT'" \
  --time-start $(date -u -v-30M '+%Y-%m-%dT%H:%M:%SZ') \
  --time-end $(date -u '+%Y-%m-%dT%H:%M:%SZ')

# Search for a specific destination port
oci logging-search search-logs \
  --search-query "search \"${LOG_GROUP_ID}/${LOG_ID}\" | where data.dstPort = '443'" \
  --time-start $(date -u -v-1H '+%Y-%m-%dT%H:%M:%SZ') \
  --time-end $(date -u '+%Y-%m-%dT%H:%M:%SZ')
```

> On Linux, replace `-v-30M` with `-d '30 minutes ago'` in the `date` command.

---

## Enable Flow Logs on Private Subnet (Optional)

The `main.tf` includes a commented-out block for enabling flow logs on `subnet-private`. To activate it:

1. Open `main.tf`
2. Uncomment the `resource "oci_logging_log" "flow_log_private_subnet"` block
3. Add `private_subnet_id` to `terraform.tfvars`:
   ```hcl
   private_subnet_id = "ocid1.subnet.oc1.iad.aaaa..."
   ```
4. Add the variable to `variables.tf` if not already present
5. Run `terraform apply`

---

## Extend Log Retention

The default retention is 30 days. To extend:

```hcl
# In terraform.tfvars
log_retention_days = 90
```

Then:
```bash
terraform apply
```

For long-term archival, add an OCI Service Connector to copy logs to Object Storage:

```hcl
# Example Service Connector (add to main.tf for archival)
resource "oci_sch_service_connector" "flow_log_archival" {
  compartment_id = var.compartment_ocid
  display_name   = "flow-log-to-object-storage"

  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = oci_logging_log_group.lab_network_logs.id
      log_id         = oci_logging_log.flow_log_public_subnet.id
    }
  }

  target {
    kind      = "objectStorage"
    bucket_name = "oci-lab-flow-log-archive"
  }
}
```

---

## Network Command Center (Console only)

Network Command Center is not provisioned via Terraform — it is always available in the console and auto-discovers your network topology.

Open it directly:
```bash
terraform output -raw console_url_ncc
```

From NCC you can:
- View the **Topology** of `lab-vcn` — all subnets, gateways, and route connections visualised
- Run ad-hoc **Path Analyzer** tests (the saved tests from Chapter 05 also appear here)
- View **Network Metrics** for VNICs in the VCN

---

## Destroy Resources

```bash
terraform destroy
```

This deletes the Log Group and Flow Log. Historical log data is purged. This does not affect the VCN or any compute resources.

---

## Files in This Directory

| File | Purpose |
|---|---|
| `provider.tf` | OCI provider configuration |
| `variables.tf` | Input variable declarations |
| `main.tf` | Log Group + Flow Log resources |
| `outputs.tf` | Log OCIDs + console URLs |
| `terraform.tfvars.example` | Template — copy to `terraform.tfvars` |

---

## Lab Complete 🎉

You have now automated the full lab with Terraform:

| Chapter | Terraform Resources |
|---|---|
| 01 — VCN & Subnets | `oci_core_vcn`, `oci_core_subnet` × 2 |
| 02 — Gateways | `oci_core_internet_gateway`, `oci_core_nat_gateway`, `oci_core_service_gateway` |
| 03 — Route Tables | `oci_core_route_table` × 2, `oci_core_route_table_attachment` × 2 |
| 04 — NSG Rules | `oci_core_network_security_group` × 2, security rules × 6 |
| 05 — Path Analyzer | `oci_vn_monitoring_path_analyzer_test` × 3 |
| 06 — Flow Logs | `oci_logging_log_group`, `oci_logging_log` |

**Total resources provisioned: ~20**

---

## Full Teardown (All Chapters)

Destroy in **reverse order** to respect resource dependencies:

```bash
# Chapter 06 first (no dependents)
cd chapters/06-flow-logs-ncc/terraform && terraform destroy -auto-approve

# Chapter 05
cd ../../05-run-path-analyzer/terraform && terraform destroy -auto-approve

# Chapter 04
cd ../../04-apply-nsg-rules/terraform && terraform destroy -auto-approve

# Chapter 03
cd ../../03-configure-route-tables/terraform && terraform destroy -auto-approve

# Chapter 02
cd ../../02-attach-gateways/terraform && terraform destroy -auto-approve

# Chapter 01 last (VCN must be emptied before it can be deleted)
cd ../../01-create-vcn-subnets/terraform && terraform destroy -auto-approve
```

---

*← [Back to main README](../../../README.md)*
