# Terraform — Chapter 01: Create VCN & Subnets

This module provisions the foundational OCI network resources:
- **`lab-vcn`** — Virtual Cloud Network (`10.0.0.0/16`)
- **`subnet-public`** — Public subnet (`10.0.1.0/24`)
- **`subnet-private`** — Private subnet (`10.0.2.0/24`)

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Terraform | >= 1.3.0 — [Install guide](https://developer.hashicorp.com/terraform/install) |
| OCI Provider | >= 5.0.0 (auto-installed by `terraform init`) |
| OCI CLI configured | API key generated and `~/.oci/config` present |
| IAM permission | `manage virtual-network-family` in the target compartment |

### Install Terraform

```bash
# macOS (Homebrew)
brew tap hashicorp/tap && brew install hashicorp/tap/terraform

# Linux (apt)
sudo apt-get install -y gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify
terraform version
```

### Configure OCI API Key

If you haven't already set up an API key:

1. **OCI Console** → Profile (top-right) → **My Profile** → **API Keys** → **Add API Key**
2. Download the private key and note the fingerprint shown
3. Create `~/.oci/config`:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaa...
fingerprint=aa:bb:cc:dd:...
tenancy=ocid1.tenancy.oc1..aaaa...
region=us-ashburn-1
key_file=~/.oci/oci_api_key.pem
```

```bash
# Verify OCI CLI connectivity
oci iam region list --output table
```

---

## Steps to Run

### 1 — Clone and navigate

```bash
cd chapters/01-create-vcn-subnets/terraform
```

### 2 — Create your variables file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your tenancy/compartment OCIDs:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaa..."
user_ocid        = "ocid1.user.oc1..aaaa..."
fingerprint      = "aa:bb:cc:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.compartment.oc1..aaaa..."
```

> **Get your OCIDs:**
> ```bash
> # Tenancy
> oci iam tenancy get --query 'data.id' --raw-output
> # Compartment
> oci iam compartment list --query "data[?name=='<your-compartment>'].id|[0]" --raw-output
> ```

### 3 — Initialise Terraform

Downloads the OCI provider plugin:

```bash
terraform init
```

Expected output:
```
Initializing provider plugins...
- Installing oracle/oci v5.x.x...
Terraform has been successfully initialized!
```

### 4 — Preview the execution plan

```bash
terraform plan
```

Review the plan output. You should see **3 resources to add**:
- `oci_core_vcn.lab_vcn`
- `oci_core_subnet.public`
- `oci_core_subnet.private`

### 5 — Apply

```bash
terraform apply
```

Type `yes` when prompted. Terraform creates all three resources in parallel where dependencies allow.

Expected output:
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
vcn_id           = "ocid1.vcn.oc1.iad.aaaa..."
public_subnet_id = "ocid1.subnet.oc1.iad.aaaa..."
private_subnet_id = "ocid1.subnet.oc1.iad.aaaa..."
```

### 6 — Save output values for later chapters

Subsequent chapters need the VCN and subnet OCIDs. Save them:

```bash
terraform output -json > ../tf-outputs.json
```

Or capture individually:

```bash
export TF_VCN_ID=$(terraform output -raw vcn_id)
export TF_PUBLIC_SUBNET_ID=$(terraform output -raw public_subnet_id)
export TF_PRIVATE_SUBNET_ID=$(terraform output -raw private_subnet_id)

echo "VCN: $TF_VCN_ID"
```

---

## Verify in OCI Console

After `terraform apply`:

1. Navigate to **Networking** → **Virtual Cloud Networks**
2. Confirm `lab-vcn` appears with CIDR `10.0.0.0/16`
3. Click `lab-vcn` → **Subnets** and confirm both subnets exist

---

## State File

Terraform tracks created resources in `terraform.tfstate`. This file contains sensitive data (OCIDs) and is listed in `.gitignore` — **do not commit it**.

For team use, configure a remote backend (OCI Object Storage):

```hcl
# Add to provider.tf for shared state
terraform {
  backend "s3" {
    bucket   = "my-tf-state-bucket"
    key      = "oci-lab/chapter01/terraform.tfstate"
    region   = "us-ashburn-1"
    endpoint = "https://<namespace>.compat.objectstorage.<region>.oraclecloud.com"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
```

---

## Destroy Resources

To tear down only this chapter's resources:

```bash
terraform destroy
```

> ⚠️ Destroy chapters in **reverse order** (06 → 01) to avoid dependency errors. Later chapters create resources that depend on the VCN created here.

---

## Files in This Directory

| File | Purpose |
|---|---|
| `provider.tf` | OCI provider version and authentication |
| `variables.tf` | All input variable declarations |
| `main.tf` | VCN and subnet resource definitions |
| `outputs.tf` | Exported values (VCN OCID, subnet OCIDs) |
| `terraform.tfvars.example` | Template — copy to `terraform.tfvars` |
| `.terraform/` | Provider plugins (auto-generated, gitignored) |
| `terraform.tfstate` | State file (auto-generated, gitignored) |

---

## Next Chapter

➡️ [Chapter 02 — Attach Gateways](../../02-attach-gateways/terraform/README.md)
