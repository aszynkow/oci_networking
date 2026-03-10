# Chapter 06 — VCN Flow Logs & Network Command Center

**Estimated time:** ~12 minutes  
**Segment:** Lab Step 6 of 6  
**Prerequisite:** [Chapter 05 — Run Path Analyzer](../05-run-path-analyzer/README.md)

---

## Objective

1. **Enable VCN Flow Logs** on `subnet-public` to capture accepted and rejected traffic
2. **Generate traffic** through the subnet and observe log records
3. **Query Flow Logs** in OCI Logging
4. **Explore Network Command Center** — topology view, reachability status, and metrics

---

## Part A — VCN Flow Logs

### What Are VCN Flow Logs?

VCN Flow Logs capture metadata about accepted and rejected traffic on a per-subnet or per-VNIC basis. They do **not** capture packet payloads — only connection metadata.

**Each log record includes:**

| Field | Description |
|---|---|
| `srcAddr` | Source IP address |
| `dstAddr` | Destination IP address |
| `srcPort` | Source port |
| `dstPort` | Destination port |
| `protocol` | IP protocol number (6=TCP, 17=UDP, 1=ICMP) |
| `action` | `ACCEPT` or `REJECT` |
| `bytes` | Bytes transferred in the flow |
| `packets` | Packet count |
| `startTime` / `endTime` | Flow window timestamps |
| `vnicId` | OCID of the VNIC |
| `subnetId` | OCID of the subnet |

---

### Step A1 — Enable Flow Logging on subnet-public

1. Navigate to **Observability & Management** → **Logging** → **Log Groups**
2. Click **Create Log Group**

   | Field | Value |
   |---|---|
   | **Name** | `lab-network-logs` |
   | **Compartment** | *(your compartment)* |
   | **Description** | VCN flow logs for OCI networking lab |

3. Click **Create**

> **Console path:** Observability & Management → Logging → Log Groups → Create Log Group

---

### Step A2 — Enable the Flow Log

**Method 1 — From the Logging service:**

1. Navigate to **Logging** → **Logs**
2. Click **Enable Service Log**
3. Fill in:

   | Field | Value |
   |---|---|
   | **Service** | Virtual Cloud Network |
   | **Resource** | `subnet-public` |
   | **Log Category** | Flow Logs (All records) |
   | **Log Name** | `flow-log-subnet-public` |
   | **Log Group** | `lab-network-logs` |

4. Click **Enable Log**

**Method 2 — From the VCN (alternative):**

1. Navigate to **Networking** → **Virtual Cloud Networks** → `lab-vcn`
2. Click **Subnets** → `subnet-public`
3. Scroll to the **Logs** section
4. Click **Enable** next to Flow Logs
5. Select log group `lab-network-logs` and click **Enable**

---

### Step A3 — Generate Traffic

With flow logging enabled, generate some traffic to create log records:

**Option A — Ping from a VM in subnet-public:**
```bash
# SSH into Web VM (if available)
ping -c 5 8.8.8.8
curl https://oracle.com
```

**Option B — Use OCI Cloud Shell:**
1. Open **Cloud Shell** (top-right toolbar)
2. Attempt a connection to your VM's public IP:
   ```bash
   curl -m 5 http://<web-vm-public-ip>/
   ```

**Option C — Use Path Analyzer to trigger evaluation:**
Re-run the path analysis tests from Chapter 05 — these do not generate flow log records but confirm the security posture.

> Flow logs typically appear within **2–5 minutes** of traffic occurring.

---

### Step A4 — View Flow Logs

1. Navigate to **Observability & Management** → **Logging** → **Logs**
2. Click `flow-log-subnet-public`
3. Click **Explore Log** (opens Log Explorer)

**In Log Explorer:**

1. Set the **Time Range** to the last 15 minutes
2. Click **Run** to execute the default query
3. Log records appear in the results panel

**Filter by REJECT only:**
```
search "REJECT"
```
Or use the query editor:
```sql
search "action='REJECT'"
```

**Filter by destination port 443:**
```sql
search "dstPort=443"
```

**View a full log record:**
Click any record to expand its JSON structure. Key fields to note:
- `data.action` — `ACCEPT` or `REJECT`
- `data.srcAddr` / `data.dstAddr`
- `data.dstPort`
- `data.bytes` — total bytes in this flow window

---

### Step A5 — Correlate a REJECT Record

If you see a `REJECT` record:

1. Note the `srcAddr`, `dstAddr`, and `dstPort`
2. Go to **Path Analyzer** and create a new analysis with those exact values
3. Path Analyzer will show you which Security List or NSG rule caused the rejection
4. This is the standard workflow for diagnosing unexpected blocked traffic in production

---

## Part B — Network Command Center

### What is Network Command Center?

Network Command Center (NCC) is a unified pane for OCI network health, topology visualization, and reachability monitoring.

> **Console path:** Networking → Network Command Center

---

### Step B1 — Open Network Command Center

1. Navigate to **Networking** → **Network Command Center**
2. The NCC dashboard loads showing:
   - **Topology** tab — visual map of your network resources
   - **Reachability** tab — probe-based connectivity status
   - **Network metrics** — traffic and performance charts

---

### Step B2 — Explore the Topology View

1. Click the **Topology** tab
2. Select your **Compartment** from the left filter panel
3. The canvas renders your VCN with:
   - VCN boundaries
   - Subnets as nested boxes
   - Compute instances as nodes
   - Gateways (IGW, NAT GW, DRG) as icons
   - Connections/peering links as edges

4. **Click `lab-vcn`** — a side panel opens showing VCN details (CIDR, route tables, subnets)
5. **Click `subnet-public`** — view subnet details, associated route table, and VNICs
6. **Click a gateway icon** — view its configuration and state

**Topology interaction tips:**
- Use the **zoom controls** (bottom-right) to navigate large networks
- Click **Filter** to show only specific resource types
- Click **Refresh** to pick up recent configuration changes

---

### Step B3 — Check Reachability Status

1. Click the **Reachability** tab
2. Click **Create Reachability Analysis**

   | Field | Value |
   |---|---|
   | **Source** | *(your Web VM or a public IP)* |
   | **Destination** | *(App VM private IP)* |
   | **Protocol** | TCP |
   | **Port** | `8080` |

3. Click **Run**
4. The result mirrors Path Analyzer — NCC is the umbrella that hosts Path Analyzer as one of its tools

---

### Step B4 — View Network Metrics

1. Click the **Metrics** tab (or navigate to your VCN and click **Metrics** in the Resources panel)
2. Available metrics include:
   - **VnicFromNetworkBytes** — bytes received by VNICs
   - **VnicToNetworkBytes** — bytes sent by VNICs
   - **VnicFromNetworkPackets** / **VnicToNetworkPackets**
   - **VnicConntrackUtilPercent** — connection tracking utilization

3. Set the time range to **Last 1 hour** and click **Update Chart**
4. If you generated traffic in Step A3, you should see activity on the chart

---

## Verification

- [ ] Log Group `lab-network-logs` exists
- [ ] Flow log `flow-log-subnet-public` is **Active** on `subnet-public`
- [ ] At least one log record is visible in Log Explorer
- [ ] You can distinguish `ACCEPT` vs `REJECT` records
- [ ] You have opened Network Command Center and viewed the topology for `lab-vcn`
- [ ] Network Command Center shows all three gateways in the topology

---

## Key Concepts

**Flow log sampling:**  
Flow logs capture all accepted and rejected flows — there is no sampling. However, flows are aggregated into **60-second windows** by default. Multiple packets in the same flow within the window appear as one record with a cumulative byte/packet count.

**Flow logs vs packet capture:**  
Flow logs are metadata only — they do not contain packet payloads. For packet-level inspection, use **VTAP (Virtual Test Access Point)** to mirror traffic to a network packet broker or IDS.

**Log retention:**  
OCI Logging retains log data for **30 days** by default. For longer retention, configure a **Service Connector** to archive logs to Object Storage.

**NCC vs individual service pages:**  
Network Command Center is a convenience aggregator. All the same information is accessible by navigating directly to each resource (VCN, subnet, route table). NCC's value is cross-resource visibility in one screen.

---

## Lab Complete 🎉

You have completed all six chapters of the OCI Networking hands-on lab:

| ✅ | Chapter | Skill |
|---|---|---|
| ✅ | 01 — Create VCN & Subnets | Foundation networking |
| ✅ | 02 — Attach Gateways | IGW, NAT GW, Service GW |
| ✅ | 03 — Configure Route Tables | Traffic routing |
| ✅ | 04 — Apply NSG Rules | Micro-segmentation |
| ✅ | 05 — Run Path Analyzer | Troubleshooting reachability |
| ✅ | 06 — Flow Logs & NCC | Traffic visibility & monitoring |

---

## Clean Up (Optional)

To avoid incurring costs, delete lab resources in this order:

1. Delete compute instances (if any)
2. Remove NSG associations from VNICs
3. Delete NSGs (`NSG-Web`, `NSG-App`)
4. Delete route tables (`rt-public`, `rt-private`)
5. Delete gateways (IGW, NAT GW, Service GW)
6. Delete subnets (`subnet-public`, `subnet-private`)
7. Delete the VCN (`lab-vcn`)
8. Disable / delete the flow log and log group

> ⚠️ Delete resources in the order above — OCI will reject deletion of a VCN that still has attached subnets, gateways, or other dependencies.

---

## Troubleshooting

| Issue | Check |
|---|---|
| Flow logs not appearing | Allow 2–5 min; confirm the log is **Active** (not Inactive) on the subnet |
| Log Explorer shows no records | Ensure traffic was generated **after** enabling the log |
| NCC topology blank | Confirm compartment selection; NCC may take 1–2 min to render large topologies |
| Metrics show no data | Some metrics only populate when a compute instance VNIC is active in the subnet |

---

## Further Reading

- [VCN Flow Logs documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/vcn_flow_logs.htm)
- [Network Command Center documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/network_command_center.htm)
- [OCI Logging — querying logs](https://docs.oracle.com/en-us/iaas/Content/Logging/Concepts/queryingsearchinglogs.htm)
- [VTAP — traffic mirroring](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/vtap.htm)

---

*← [Back to main README](../../README.md)*
