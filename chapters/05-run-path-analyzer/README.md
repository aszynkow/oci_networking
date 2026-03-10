# Chapter 05 — Run Path Analyzer

**Estimated time:** ~12 minutes  
**Segment:** Lab Step 5 of 6  
**Prerequisite:** [Chapter 04 — Apply NSG Rules](../04-apply-nsg-rules/README.md)

---

## Objective

Use OCI **Path Analyzer** to simulate and verify traffic paths through the network:

1. **Test 1 — Allowed path:** Internet → Web VM on port 443 (should PASS)
2. **Test 2 — Blocked path:** Internet → App VM on port 8080 (should DROP)
3. **Test 3 — VCN internal path:** Web VM → App VM on port 8080 (should PASS)
4. **Fix the DROP:** Identify the blocking rule and understand the output

---

## What is Path Analyzer?

Path Analyzer simulates how a packet travels through OCI networking — evaluating each route table lookup and security rule check along the way — **without sending real traffic**. It returns a hop-by-hop analysis including:

- The route table decision at each subnet egress
- Every Security List and NSG rule evaluated
- The exact rule or configuration that causes a DROP
- Whether the path reaches the intended destination

> **Console path:** Networking → Network Command Center → Path Analyzer

---

## Step 1 — Navigate to Path Analyzer

1. Open the **Navigation Menu** → **Networking**
2. Click **Network Command Center**
3. In the left panel, click **Path Analyzer**

   > Alternatively: Networking → **Path Analyzer** (direct link in some regions)

---

## Test 1 — Allowed Path: Internet → Web VM (port 443)

### Configure the test

1. Click **Create Path Analysis**
2. Fill in the **Source** section:

   | Field | Value |
   |---|---|
   | **Source Type** | On-premises / Internet |
   | **Source IP** | `8.8.8.8` *(any public IP)* |

3. Fill in the **Destination** section:

   | Field | Value |
   |---|---|
   | **Destination Type** | IP Address |
   | **Destination IP** | *(public IP of your Web VM, or `10.0.1.10` as a placeholder)* |
   | **Protocol** | TCP |
   | **Destination Port** | `443` |

4. Click **Run Analysis**

### Expected result: REACHABLE ✅

The output should show:
- **Path Status: Reachable**
- Hop 1: Traffic enters via Internet Gateway `lab-igw`
- Hop 2: Route table `rt-public` matched — `0.0.0.0/0 → lab-igw`
- Hop 3: NSG-Web rule evaluated — ingress TCP 443 from `0.0.0.0/0` → **Allowed**
- Final hop: Packet delivered to destination VNIC

---

## Test 2 — Blocked Path: Internet → App VM (port 8080)

### Configure the test

1. Click **Create Path Analysis**
2. **Source:**

   | Field | Value |
   |---|---|
   | **Source Type** | On-premises / Internet |
   | **Source IP** | `8.8.8.8` |

3. **Destination:**

   | Field | Value |
   |---|---|
   | **Destination Type** | IP Address |
   | **Destination IP** | `10.0.2.10` *(App VM private IP)* |
   | **Protocol** | TCP |
   | **Destination Port** | `8080` |

4. Click **Run Analysis**

### Expected result: NOT REACHABLE ❌

The output should show:
- **Path Status: Indeterminate / Not Reachable**
- The path will fail at the route table or security layer — the private subnet has no route from the internet, and NSG-App only allows port 8080 from NSG-Web (not from `0.0.0.0/0`)

### Reading the DROP reason

Look at the **Hop Details** panel:
- Each hop shows the rules evaluated
- A red ❌ icon indicates the point of failure
- The **Reason** field will show the specific rule or missing route that caused the drop
- Example: `"No matching route rule for destination 10.0.2.10 from Internet Gateway"`

---

## Test 3 — Internal Path: Web VM → App VM (port 8080)

### Configure the test

1. Click **Create Path Analysis**
2. **Source:**

   | Field | Value |
   |---|---|
   | **Source Type** | Compute Instance or IP |
   | **Source IP** | `10.0.1.10` *(Web VM private IP)* |
   | **Source VCN** | `lab-vcn` |
   | **Source Subnet** | `subnet-public` |

3. **Destination:**

   | Field | Value |
   |---|---|
   | **Destination Type** | IP Address |
   | **Destination IP** | `10.0.2.10` *(App VM private IP)* |
   | **Protocol** | TCP |
   | **Destination Port** | `8080` |

4. Click **Run Analysis**

### Expected result: REACHABLE ✅

The path analysis shows:
- VCN internal routing — no gateway hop needed (traffic stays within VCN)
- NSG-App ingress rule for port 8080 evaluated: source is `NSG-Web` (matched) → **Allowed**
- Packet delivered to App VM VNIC

---

## Step 2 — Simulate a Fix Using Path Analyzer

### Scenario: App VM cannot reach the internet on port 443

1. Create a new analysis:
   - **Source:** `10.0.2.10` (App VM, `subnet-private`)
   - **Destination:** `8.8.8.8` (internet)
   - **Protocol:** TCP, **Port:** `443`

2. Run and observe — if your NSG-App egress rule allows all traffic, and the NAT GW route rule exists, this should pass.

3. **To simulate a break:** Temporarily remove the `0.0.0.0/0 → lab-nat-gw` rule from `rt-private` (do not save), then re-run the analysis to see the route failure.

4. **Re-add the route rule** after observing the DROP.

---

## Step 3 — Save and Share a Path Analysis

Path analyses can be saved for documentation and shared with the team:

1. After running an analysis, click **Save**
2. Give it a descriptive name, e.g. `internet-to-web-443-allowed`
3. Saved analyses appear in the **Saved Path Analyses** list and can be re-run at any time to detect configuration drift

---

## Verification

- [ ] Test 1 (Internet → Web VM port 443) returns **Reachable**
- [ ] Test 2 (Internet → App VM port 8080) returns **Not Reachable** with a clear DROP reason
- [ ] Test 3 (Web VM → App VM port 8080) returns **Reachable**
- [ ] You have identified and can explain the DROP reason from Test 2

---

## Key Concepts

**Path Analyzer does not send real traffic:**  
It is a simulation based on the current state of your OCI network configuration (route tables, NSGs, Security Lists, DRG attachments). It is safe to run in production at any time.

**Path Analyzer covers:**
- VCN local routing
- Route table evaluation
- Security List rule evaluation
- NSG rule evaluation
- Gateway traversal (IGW, NAT, SGW, DRG, LPG)
- Cross-VCN paths via LPG or DRG
- On-premises paths via FastConnect or VPN

**Path Analyzer does NOT cover:**
- OS-level firewall rules (iptables, firewalld, Windows Firewall)
- Application-layer filtering
- Third-party network appliances unless modeled as OCI resources

**When you get a DROP but traffic seems to work:**  
Check OS-level firewall rules on the instance. OCI Path Analyzer only models the OCI network layer.

---

## Troubleshooting

| Issue | Check |
|---|---|
| "Indeterminate" result | Often means the source or destination IP is ambiguous — specify VCN and subnet for private IPs |
| Analysis won't run | Ensure IAM permission: `use virtual-network-family` in the compartment |
| Unexpected PASS on blocked test | Security List may be allowing the traffic even though NSG does not — both are evaluated and the union applies |

---

## Next Chapter

➡️ [Chapter 06 — VCN Flow Logs & Network Command Center](../06-flow-logs-ncc/README.md)
