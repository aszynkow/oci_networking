# Chapter 02 — Attach Gateways

**Estimated time:** ~8 minutes  
**Segment:** Lab Step 2 of 6  
**Prerequisite:** [Chapter 01 — Create VCN & Subnets](../01-create-vcn-subnets/README.md)

---

## Objective

Add the three gateways required for this lab:
- **Internet Gateway (IGW)** — inbound + outbound internet for the public subnet
- **NAT Gateway** — outbound-only internet for the private subnet
- **Service Gateway** — private access to Oracle Services (Object Storage, OCI APIs)

---

## Gateway Reference

| Gateway | Direction | Internet IP Required | Use Case |
|---|---|---|---|
| Internet Gateway | Inbound + Outbound | Yes (on resource VNIC) | Public-facing workloads |
| NAT Gateway | Outbound only | No | Private VMs downloading patches, calling APIs |
| Service Gateway | Oracle Services only | No | Access OCI Object Storage, APIs without internet |

> **Hard limits:** Only **1 IGW**, **1 NAT GW**, and **1 Service GW** are allowed per VCN. These cannot be increased.

---

## Step 1 — Create the Internet Gateway

1. Navigate to **Networking** → **Virtual Cloud Networks** → `lab-vcn`
2. In the left Resources panel, click **Internet Gateways**
3. Click **Create Internet Gateway**
4. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `lab-igw` |
   | **Compartment** | *(your compartment)* |
   | **Enabled** | ✅ Yes |

5. Click **Create Internet Gateway**

> **Console path:** VCN detail → Resources → Internet Gateways → Create Internet Gateway

---

## Step 2 — Create the NAT Gateway

1. In the left Resources panel, click **NAT Gateways**
2. Click **Create NAT Gateway**
3. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `lab-nat-gw` |
   | **Compartment** | *(your compartment)* |
   | **Public IP Address** | Ephemeral Public IP *(default)* |

4. Click **Create NAT Gateway**

> The NAT Gateway automatically gets an ephemeral public IP. To use a reserved IP (for IP allowlisting on external services), select **Reserved Public IP** and either create or select an existing one.

> **Console path:** VCN detail → Resources → NAT Gateways → Create NAT Gateway

---

## Step 3 — Create the Service Gateway

1. In the left Resources panel, click **Service Gateways**
2. Click **Create Service Gateway**
3. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `lab-sgw` |
   | **Compartment** | *(your compartment)* |
   | **Services** | **All \<Region\> Services in Oracle Services Network** |

4. Click **Create Service Gateway**

> **Why "All Services"?** This includes Object Storage, OCI APIs, and all other services reachable via the Oracle Services Network. You can restrict to Object Storage only if required by your security posture.

> **Console path:** VCN detail → Resources → Service Gateways → Create Service Gateway

---

## Step 4 — Verify Gateway States

1. Check each gateway shows **State: Available**
2. The IGW should show **Enabled: Yes**

Summary of expected resources:

| Resource | Name | State |
|---|---|---|
| Internet Gateway | `lab-igw` | Available |
| NAT Gateway | `lab-nat-gw` | Available |
| Service Gateway | `lab-sgw` | Available |

---

## ⚠️ Important: Gateways Are Not Yet Active

Creating a gateway **does not route traffic through it**. Traffic only flows through a gateway when a **route rule** in a subnet's route table explicitly points to it.

You will configure route rules in **Chapter 03**.

---

## Verification

- [ ] Internet Gateway `lab-igw` exists and is **Enabled**
- [ ] NAT Gateway `lab-nat-gw` exists and has a public IP assigned
- [ ] Service Gateway `lab-sgw` exists and targets **All Services**
- [ ] All three gateways show **State: Available**

---

## Key Concepts

**IGW vs NAT GW — what's the difference?**

```
Public Subnet + IGW:
  VM (10.0.1.10) ←──── inbound:443 ──── Internet ✅
  VM (10.0.1.10) ────► outbound ────────► Internet ✅

Private Subnet + NAT GW:
  VM (10.0.2.10) ←──── inbound ────────X Internet ❌ (blocked)
  VM (10.0.2.10) ────► outbound ────────► Internet ✅ (via NAT)
```

The NAT GW translates the private IP to its own public IP for outbound traffic. The source IP seen by the internet is the NAT GW's IP, not the VM's.

**Service Gateway — no internet hop:**  
Traffic to Oracle Services via a Service GW never leaves Oracle's network. This improves security and avoids egress charges.

---

## Troubleshooting

| Issue | Check |
|---|---|
| "Limit reached" creating IGW | Only 1 IGW per VCN. Check if one already exists from VCN Wizard. |
| NAT GW shows no public IP | Ensure the compartment has quota for Reserved Public IPs if you chose reserved. |
| Service GW not visible | Confirm you are in the correct region and compartment. |

---

## Next Chapter

➡️ [Chapter 03 — Configure Route Tables](../03-configure-route-tables/README.md)
