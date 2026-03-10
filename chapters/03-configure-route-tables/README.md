# Chapter 03 — Configure Route Tables

**Estimated time:** ~8 minutes  
**Segment:** Lab Step 3 of 6  
**Prerequisite:** [Chapter 02 — Attach Gateways](../02-attach-gateways/README.md)

---

## Objective

Create two dedicated route tables and associate them with the correct subnets:

| Route Table | Associated Subnet | Default Route Target |
|---|---|---|
| `rt-public` | `subnet-public` | Internet Gateway (`lab-igw`) |
| `rt-private` | `subnet-private` | NAT Gateway (`lab-nat-gw`) |

Add an additional Oracle Services route rule to the private route table for Service Gateway access.

---

## Route Table Concepts

A route table is a set of rules (route rules) that tells OCI where to send traffic leaving a subnet. Each subnet is associated with **exactly one** route table. Multiple subnets can share the same route table.

**Route rule fields:**

| Field | Description |
|---|---|
| **Destination Type** | CIDR Block or Service (for Service Gateway) |
| **Destination** | Target CIDR (e.g. `0.0.0.0/0`) or Oracle Service |
| **Target** | The gateway to send matching traffic to |
| **Description** | Optional human-readable note |

> Rules are evaluated as **longest-prefix match**, not top-down. The most specific CIDR always wins.

---

## Step 1 — Create the Public Route Table

1. Navigate to **Networking** → **Virtual Cloud Networks** → `lab-vcn`
2. In the left Resources panel, click **Route Tables**
3. Click **Create Route Table**
4. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `rt-public` |
   | **Compartment** | *(your compartment)* |

5. Under **Route Rules**, click **+ Another Route Rule**
6. Add the internet default route:

   | Field | Value |
   |---|---|
   | **Destination Type** | CIDR Block |
   | **Destination CIDR** | `0.0.0.0/0` |
   | **Target Type** | Internet Gateway |
   | **Target** | `lab-igw` |
   | **Description** | Default route to internet via IGW |

7. Click **Create Route Table**

---

## Step 2 — Create the Private Route Table

1. Click **Create Route Table** again
2. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `rt-private` |
   | **Compartment** | *(your compartment)* |

3. Add **Rule 1** — NAT GW default route:

   | Field | Value |
   |---|---|
   | **Destination Type** | CIDR Block |
   | **Destination CIDR** | `0.0.0.0/0` |
   | **Target Type** | NAT Gateway |
   | **Target** | `lab-nat-gw` |
   | **Description** | Default outbound route via NAT GW |

4. Click **+ Another Route Rule** to add **Rule 2** — Service Gateway:

   | Field | Value |
   |---|---|
   | **Destination Type** | Service |
   | **Destination Service** | **All \<Region\> Services in Oracle Services Network** |
   | **Target Type** | Service Gateway |
   | **Target** | `lab-sgw` |
   | **Description** | Oracle Services via Service GW (no internet hop) |

5. Click **Create Route Table**

---

## Step 3 — Associate Route Tables with Subnets

By default, subnets use the VCN's Default Route Table. You need to reassign each subnet to the correct custom route table.

### Associate `rt-public` with `subnet-public`

1. Click **Subnets** in the left Resources panel
2. Click `subnet-public`
3. Click **Edit**
4. Change **Route Table** from `Default Route Table` to `rt-public`
5. Click **Save Changes**

### Associate `rt-private` with `subnet-private`

1. Click **Subnets** → `subnet-private`
2. Click **Edit**
3. Change **Route Table** from `Default Route Table` to `rt-private`
4. Click **Save Changes**

---

## Step 4 — Verify Route Table Associations

1. Navigate back to **Route Tables** in the VCN
2. Confirm both route tables are listed with the correct rules:

**`rt-public` expected rules:**
```
Destination: 0.0.0.0/0  →  Target: lab-igw (Internet Gateway)
```

**`rt-private` expected rules:**
```
Destination: 0.0.0.0/0  →  Target: lab-nat-gw (NAT Gateway)
Destination: All <Region> Services  →  Target: lab-sgw (Service Gateway)
```

3. Click each subnet and confirm the **Route Table** field shows the correct table.

---

## Verification

- [ ] Route table `rt-public` exists with one rule: `0.0.0.0/0` → `lab-igw`
- [ ] Route table `rt-private` exists with two rules: `0.0.0.0/0` → `lab-nat-gw` and All Services → `lab-sgw`
- [ ] `subnet-public` is associated with `rt-public`
- [ ] `subnet-private` is associated with `rt-private`

---

## Key Concepts

**Why not use the Default Route Table?**  
The Default Route Table is created automatically with the VCN and is shared. Using dedicated route tables per subnet gives you cleaner separation of concerns and makes it easier to reason about routing policy per tier.

**Service Gateway route rule — destination type is "Service", not CIDR:**  
This is a common source of confusion. When routing to a Service Gateway, you must choose **Destination Type: Service** and select the Oracle Services bundle. You cannot route to a Service GW using a CIDR block rule.

**Route rule limits:**
- Max **200 rules** per route table (soft)
- Max **300 route tables** per VCN (soft default: 10)

**VCN local traffic (same VCN):**  
Traffic between resources *within the same VCN* is routed automatically — no route rule needed. Route rules only govern traffic leaving a subnet toward a gateway.

---

## Architecture After This Chapter

```
subnet-public (10.0.1.0/24)
  └── rt-public
        └── 0.0.0.0/0 → lab-igw → Internet

subnet-private (10.0.2.0/24)
  └── rt-private
        ├── 0.0.0.0/0 → lab-nat-gw → Internet (outbound only)
        └── All OCI Services → lab-sgw → Oracle Services Network
```

---

## Troubleshooting

| Issue | Check |
|---|---|
| Route table not visible in subnet edit | Ensure route table is in the same compartment as the subnet |
| Service GW rule fails to save | Confirm the Service GW exists and targets the same service bundle selected in the rule |
| Traffic still not routing after association | Check Security Lists and NSGs — routing and security are independent; both must allow traffic |

---

## Next Chapter

➡️ [Chapter 04 — Apply NSG Rules](../04-apply-nsg-rules/README.md)
