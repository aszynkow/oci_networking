# Chapter 01 — Create VCN & Subnets

**Estimated time:** ~10 minutes  
**Segment:** Lab Step 1 of 6

---

## Objective

Create the foundational network: one VCN with a public and a private subnet. All subsequent lab chapters build on this VCN.

## What You Will Create

| Resource | Name | CIDR |
|---|---|---|
| VCN | `lab-vcn` | `10.0.0.0/16` |
| Public Subnet | `subnet-public` | `10.0.1.0/24` |
| Private Subnet | `subnet-private` | `10.0.2.0/24` |

---

## Step 1 — Navigate to Networking

1. Sign in to the [OCI Console](https://cloud.oracle.com)
2. Open the **Navigation Menu** (☰ top-left)
3. Select **Networking** → **Virtual Cloud Networks**
4. Confirm you are in the correct **Compartment** (top of left panel)

---

## Step 2 — Create the VCN

> **Option A — VCN Wizard (recommended for first run)**  
> Click **Start VCN Wizard** → **Create VCN with Internet Connectivity** → **Start VCN Wizard**  
> The wizard auto-creates the VCN, public/private subnets, IGW, NAT GW, and default route tables in one flow. If you use the wizard, skip to the [Verification](#verification) section.

> **Option B — Manual creation (used in this lab for full visibility)**  
> Follow Steps 2–6 below.

1. Click **Create VCN**
2. Fill in the following fields:

   | Field | Value |
   |---|---|
   | **Name** | `lab-vcn` |
   | **Compartment** | *(your target compartment)* |
   | **IPv4 CIDR Block** | `10.0.0.0/16` |
   | **DNS Resolution** | ✅ Enabled |
   | **DNS Label** | `labvcn` |

3. Leave all other fields as default
4. Click **Create VCN**

> **Console path:** Networking → Virtual Cloud Networks → Create VCN

---

## Step 3 — Create the Public Subnet

1. From the VCN detail page, click **Subnets** in the left Resources panel
2. Click **Create Subnet**
3. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `subnet-public` |
   | **Subnet Type** | Regional |
   | **IPv4 CIDR Block** | `10.0.1.0/24` |
   | **Route Table** | *(leave as Default Route Table for now)* |
   | **Subnet Access** | **Public Subnet** |
   | **DNS Label** | `subnetpub` |
   | **DHCP Options** | Default DHCP Options |
   | **Security List** | Default Security List |

4. Click **Create Subnet**

---

## Step 4 — Create the Private Subnet

1. Click **Create Subnet** again
2. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `subnet-private` |
   | **Subnet Type** | Regional |
   | **IPv4 CIDR Block** | `10.0.2.0/24` |
   | **Route Table** | *(leave as Default Route Table for now — updated in Chapter 03)* |
   | **Subnet Access** | **Private Subnet** |
   | **DNS Label** | `subnetprv` |
   | **DHCP Options** | Default DHCP Options |
   | **Security List** | Default Security List |

3. Click **Create Subnet**

---

## Step 5 — Review DNS Labels

DNS labels enable internal hostname resolution within the VCN. The resulting hostnames follow the pattern:

```
<hostname>.<subnet-dns-label>.<vcn-dns-label>.oraclevcn.com
```

For example:
```
web-vm.subnetpub.labvcn.oraclevcn.com
```

1. From the VCN detail page, confirm the **DNS Domain Name** field shows `labvcn.oraclevcn.com`
2. Click each subnet and confirm the **DNS Domain Name** shows the correct label

---

## Verification

After completing this chapter, confirm:

- [ ] VCN `lab-vcn` exists with CIDR `10.0.0.0/16`
- [ ] VCN **DNS Label** is `labvcn`
- [ ] Subnet `subnet-public` exists with CIDR `10.0.1.0/24` and type **Public**
- [ ] Subnet `subnet-private` exists with CIDR `10.0.2.0/24` and type **Private**
- [ ] Both subnets show **State: Available**

---

## Key Concepts

**Why regional subnets?**  
Regional subnets span all Availability Domains in the region, giving you flexibility to place resources in any AD without being locked to a specific one. Oracle recommends regional subnets for new deployments.

**Why separate public and private?**  
Resources in a public subnet *can* have public IPs and receive inbound internet traffic (subject to Security List / NSG rules). Resources in a private subnet have no public IP — they can initiate outbound traffic via a NAT Gateway but are not directly reachable from the internet.

**OCI reserves 3 IPs per subnet:**  
- `.1` — default gateway
- `.2` — reserved
- `.255` — broadcast (not used but reserved)

A `/24` subnet gives you **253 usable host addresses**.

---

## Troubleshooting

| Issue | Check |
|---|---|
| Cannot create VCN | Verify IAM policy: `allow group <group> to manage virtual-network-family in compartment <name>` |
| DNS label rejected | Labels must be 1–15 chars, letters and numbers only, starting with a letter |
| CIDR conflict | Ensure CIDR does not overlap with other VCNs in the same region/compartment |

---

## Next Chapter

➡️ [Chapter 02 — Attach Gateways](../02-attach-gateways/README.md)
