# Terraform — Chapter 05: Path Analyzer Tests

This module creates three **saved, reusable Path Analyzer tests** in OCI VN Monitoring:

| Test Name | Source | Destination | Port | Expected |
|---|---|---|---|---|
| `internet-to-web-443` | `8.8.8.8` (internet) | Web VM | 443 | ✅ Reachable |
| `internet-to-app-8080-blocked` | `8.8.8.8` (internet) | App VM | 8080 | ❌ Not Reachable |
| `web-to-app-8080-allowed` | Web VM (`subnet-public`) | App VM (`subnet-private`) | 8080 | ✅ Reachable |

Saved tests persist in OCI and can be re-run at any time from the Console or via API to detect configuration drift.

**Depends on:** Chapter 01 (VCN + subnets), Chapter 04 (NSGs)

> **Note:** Path Analyzer tests are a **VN Monitoring** resource in OCI (`oci_vn_monitoring_path_analyzer_test`). The OCI provider version >= 5.0.0 is required.

---

## Prerequisites

- Terraform >= 1.3.0
- OCI provider >= 5.0.0
- Chapter 01 and Chapter 04 applied
- IAM permission: `use vn-monitoring-family` in the target compartment

---

## Steps to Run

### 1 — Collect outputs from previous chapters

```bash
# Chapter 01
cd ../01-create-vcn-subnets/terraform && terraform output

# Chapter 04
cd ../../04-apply-nsg-rules/terraform && terraform output
```

### 2 — Navigate to this chapter

```bash
cd ../../05-run-path-analyzer/terraform
```

### 3 — Create your variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 4 — Initialise

```bash
terraform init
```

### 5 — Plan

```bash
terraform plan
```

Expected: **3 resources to add** (`oci_vn_monitoring_path_analyzer_test` × 3)

> Also note: `oci_network_path_analyzer_path_analysis_work_request_result` is a transient resource used internally to trigger test runs. The 3 `oci_vn_monitoring_path_analyzer_test` resources are the persistent saved tests.

### 6 — Apply

```bash
terraform apply
```

Expected output:
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
path_test_internet_to_web_id  = "ocid1.pathanalyzertest.oc1.iad.aaaa..."
path_test_internet_to_app_id  = "ocid1.pathanalyzertest.oc1.iad.aaaa..."
path_test_web_to_app_id       = "ocid1.pathanalyzertest.oc1.iad.aaaa..."
console_url_path_analyzer     = "https://cloud.oracle.com/networking/network-command-center/path-analyzer?region=us-ashburn-1"
```

---

## Run the Tests in the Console

After applying, open the console URL from the output:

```bash
terraform output -raw console_url_path_analyzer
# Opens: https://cloud.oracle.com/networking/.../path-analyzer?region=...
```

1. Open the URL → you'll see the three saved tests listed
2. Click each test → click **Run Analysis**
3. Review hop-by-hop results and verify expected outcomes match

---

## Run Tests via OCI CLI

You can also trigger and poll path analysis runs from the CLI:

```bash
# Run the internet-to-web test
TEST_ID=$(terraform output -raw path_test_internet_to_web_id)

oci vn-monitoring path-analyzer-test run \
  --path-analyzer-test-id $TEST_ID

# List recent results
oci vn-monitoring path-analyzer-test-result list \
  --path-analyzer-test-id $TEST_ID \
  --query 'data[0].result-state'
```

---

## Re-running Tests to Detect Drift

A key use case for saved Path Analyzer tests is **drift detection** — confirming the network posture hasn't changed after a configuration update.

```bash
# Trigger all three tests after any infra change
for TEST_OCID in \
  $(terraform output -raw path_test_internet_to_web_id) \
  $(terraform output -raw path_test_internet_to_app_id) \
  $(terraform output -raw path_test_web_to_app_id); do
    echo "Running test: $TEST_OCID"
    oci vn-monitoring path-analyzer-test run \
      --path-analyzer-test-id $TEST_OCID
done
```

---

## Verify in OCI Console

1. Navigate to **Networking** → **Network Command Center** → **Path Analyzer**
2. Under **Saved Path Analyses**, confirm three tests are listed
3. Run each test and confirm the result matches the expected column above

---

## Destroy Resources

```bash
terraform destroy
```

Deleting Path Analyzer tests removes them from the saved list but does not affect any network resources.

---

## Files in This Directory

| File | Purpose |
|---|---|
| `provider.tf` | OCI provider configuration |
| `variables.tf` | Input variable declarations |
| `main.tf` | Three `oci_vn_monitoring_path_analyzer_test` resources |
| `outputs.tf` | Test OCIDs + console URL |
| `terraform.tfvars.example` | Template — copy to `terraform.tfvars` |

---

## Next Chapter

➡️ [Chapter 06 — VCN Flow Logs & Network Command Center](../../06-flow-logs-ncc/terraform/README.md)
