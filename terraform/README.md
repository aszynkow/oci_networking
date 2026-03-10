# OCI Terraform — Shared Reference

This directory contains shared variable definitions and provider configuration
that are referenced by each chapter's Terraform module.

Each chapter under `chapters/*/terraform/` is a **standalone Terraform root module**.
They share the same variable names and provider pattern but are run independently,
allowing you to apply chapters incrementally without a monolithic state file.

## Shared Variable Names

All chapter modules use the following variable names consistently:

| Variable | Description |
|---|---|
| `tenancy_ocid` | OCID of your OCI tenancy |
| `user_ocid` | OCID of the OCI user running Terraform |
| `fingerprint` | API key fingerprint |
| `private_key_path` | Local path to your OCI API private key (.pem) |
| `region` | OCI region identifier (e.g. `us-ashburn-1`) |
| `compartment_ocid` | OCID of the target compartment |

## Getting Your OCIDs

```bash
# Tenancy OCID
oci iam tenancy get --query 'data.id' --raw-output

# User OCID (current user)
oci iam user list --query 'data[0].id' --raw-output

# Compartment OCID
oci iam compartment list --query "data[?name=='<your-compartment>'].id | [0]" --raw-output
```

## OCI Terraform Provider Documentation

https://registry.terraform.io/providers/oracle/oci/latest/docs
