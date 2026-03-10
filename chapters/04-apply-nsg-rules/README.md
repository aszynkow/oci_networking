# Chapter 04 — Apply NSG Rules

**Estimated time:** ~10 minutes  
**Segment:** Lab Step 4 of 6  
**Prerequisite:** [Chapter 03 — Configure Route Tables](../03-configure-route-tables/README.md)

---

## Objective

Create two Network Security Groups (NSGs) implementing a two-tier security model:

| NSG | Applied to | Allows |
|---|---|---|
| `NSG-Web` | Web VMs in `subnet-public` | Ingress: HTTPS (443) and HTTP (80) from internet |
| `NSG-App` | App VMs in `subnet-private` | Ingress: port 8080 **from `NSG-Web` only** |

This demonstrates one of NSGs' key advantages over Security Lists: you can reference another NSG as the traffic source, enabling precise micro-segmentation without managing CIDR blocks.

---

## NSG vs Security List — Quick Reminder

| | Security List | NSG |
|---|---|---|
| Attached to | Subnet | VNIC (instance, LB, DB) |
| Rules apply to | All VNICs in subnet | Only VNICs explicitly added |
| Source/dest | CIDR only | CIDR **or** NSG reference |
| Oracle recommendation | Fallback baseline | ✅ Preferred |
| Hard limits | 200 ingress + 200 egress | 120 combined · 5 NSGs per VNIC |

---

## Step 1 — Create NSG-Web

1. Navigate to **Networking** → **Virtual Cloud Networks** → `lab-vcn`
2. In the left Resources panel, click **Network Security Groups**
3. Click **Create Network Security Group**
4. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `NSG-Web` |
   | **Compartment** | *(your compartment)* |

5. Click **Next** to proceed to the rules step

### Add Rule 1 — Allow HTTPS inbound from internet

Click **+ Another Rule** and fill in:

| Field | Value |
|---|---|
| **Direction** | Ingress |
| **Stateless** | No (stateful) |
| **Source Type** | CIDR |
| **Source CIDR** | `0.0.0.0/0` |
| **IP Protocol** | TCP |
| **Destination Port Range** | `443` |
| **Description** | Allow HTTPS from internet |

### Add Rule 2 — Allow HTTP inbound from internet

Click **+ Another Rule**:

| Field | Value |
|---|---|
| **Direction** | Ingress |
| **Stateless** | No (stateful) |
| **Source Type** | CIDR |
| **Source CIDR** | `0.0.0.0/0` |
| **IP Protocol** | TCP |
| **Destination Port Range** | `80` |
| **Description** | Allow HTTP from internet |

### Add Rule 3 — Allow all egress

Click **+ Another Rule**:

| Field | Value |
|---|---|
| **Direction** | Egress |
| **Stateless** | No (stateful) |
| **Destination Type** | CIDR |
| **Destination CIDR** | `0.0.0.0/0` |
| **IP Protocol** | All Protocols |
| **Description** | Allow all outbound traffic |

6. Click **Create**

---

## Step 2 — Create NSG-App

1. Click **Create Network Security Group**
2. Fill in:

   | Field | Value |
   |---|---|
   | **Name** | `NSG-App` |
   | **Compartment** | *(your compartment)* |

3. Click **Next** to proceed to the rules step

### Add Rule 1 — Allow port 8080 from NSG-Web only

> ⚠️ This rule uses **NSG-Web as the source** — this is the micro-segmentation pattern unique to NSGs.

Click **+ Another Rule**:

| Field | Value |
|---|---|
| **Direction** | Ingress |
| **Stateless** | No (stateful) |
| **Source Type** | **Network Security Group** |
| **Source NSG** | `NSG-Web` |
| **IP Protocol** | TCP |
| **Destination Port Range** | `8080` |
| **Description** | Allow app traffic from Web tier only |

### Add Rule 2 — Allow SSH for management (optional)

| Field | Value |
|---|---|
| **Direction** | Ingress |
| **Stateless** | No |
| **Source Type** | CIDR |
| **Source CIDR** | `10.0.0.0/16` *(restrict to VCN CIDR)* |
| **IP Protocol** | TCP |
| **Destination Port Range** | `22` |
| **Description** | Allow SSH from within VCN only |

### Add Rule 3 — Allow all egress

| Field | Value |
|---|---|
| **Direction** | Egress |
| **Stateless** | No |
| **Destination Type** | CIDR |
| **Destination CIDR** | `0.0.0.0/0` |
| **IP Protocol** | All Protocols |
| **Description** | Allow all outbound traffic |

4. Click **Create**

---

## Step 3 — Associate NSGs with Compute Instances

NSGs take effect only when a VNIC (compute instance, load balancer, etc.) is explicitly added to the group.

### When launching a new instance:

1. Navigate to **Compute** → **Instances** → **Create Instance**
2. In the **Networking** section, expand **Advanced options**
3. Under **Network Security Groups**, click **+ Add NSG**
4. Select `NSG-Web` (for a web-tier instance in `subnet-public`)
5. A VNIC can belong to a maximum of **5 NSGs**

### To add an NSG to an existing instance:

1. Navigate to **Compute** → **Instances** → *(select instance)*
2. Click **Attached VNICs** in the Resources panel
3. Click the VNIC name
4. Click **Edit** on the VNIC detail page
5. Under **Network Security Groups**, add `NSG-Web` or `NSG-App` as appropriate
6. Click **Save Changes**

---

## Step 4 — Verify NSG Rules

1. Navigate back to **Network Security Groups** in the VCN
2. Click `NSG-Web` → confirm 3 rules (2 ingress, 1 egress)
3. Click `NSG-App` → confirm 3 rules (2 ingress, 1 egress)
4. On the `NSG-App` ingress rule for port 8080, confirm the **Source** column shows `NSG-Web` (not a CIDR)

---

## Verification

- [ ] NSG `NSG-Web` exists with rules allowing ingress 80, 443 from `0.0.0.0/0` and all egress
- [ ] NSG `NSG-App` exists with rule allowing ingress 8080 from `NSG-Web` only
- [ ] Both NSGs show **State: Available**
- [ ] Rule count per NSG is under 120 (combined ingress + egress hard limit)

---

## Key Concepts

**Stateful vs Stateless rules:**  
- **Stateful (default):** Return traffic is automatically allowed. You only need one rule for a connection.
- **Stateless:** You must add rules for both directions explicitly. Higher performance for known traffic patterns.

**NSG rule evaluation:**  
NSG rules are evaluated as a logical union. If a VNIC belongs to multiple NSGs, the effective ruleset is the combination of all rules from all NSGs it belongs to. There is no precedence — if any rule allows traffic, it is allowed.

**Implicit deny:**  
OCI uses an implicit deny model. Any traffic not explicitly permitted by a Security List or NSG rule is **denied**. Unlike AWS Security Groups, there is no default "allow all egress" unless you create that rule.

**NSG limits (important for design):**

| Limit | Value | Type |
|---|---|---|
| NSGs per VCN | 1,000 | Soft (raiseable) |
| NSGs per VNIC | **5** | **Hard — cannot be increased** |
| Rules per NSG | **120** total | **Hard — cannot be increased** |

---

## Architecture After This Chapter

```
Internet
    │
    ▼ 443, 80
┌──────────────────────────────┐
│  subnet-public               │
│  VM-Web ──[NSG-Web]          │
│    - ingress: 80, 443        │
│    - egress: all             │
└──────────────┬───────────────┘
               │ 8080 (NSG-Web as source)
               ▼
┌──────────────────────────────┐
│  subnet-private              │
│  VM-App ──[NSG-App]          │
│    - ingress: 8080 from NSG-Web only
│    - egress: all             │
└──────────────────────────────┘
```

---

## Troubleshooting

| Issue | Check |
|---|---|
| NSG rule with NSG source not selectable | Source NSG must be in the **same VCN** |
| Traffic still blocked after adding NSG | Also check the subnet's Security List — both must allow the traffic |
| "5 NSG limit" hit | Remove unused NSG associations from the VNIC before adding a new one |
| Rules > 120 | Split into a second NSG and attach both to the VNIC (up to the 5-per-VNIC limit) |

---

## Next Chapter

➡️ [Chapter 05 — Run Path Analyzer](../05-run-path-analyzer/README.md)
