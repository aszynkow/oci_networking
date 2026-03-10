# OCI Networking — Hands-On Lab

> **Oracle Cloud Infrastructure (OCI) Networking Enablement**  
> 60-minute team workshop · 6 hands-on chapters

---

## Overview

Oracle Cloud Infrastructure Networking provides a software-defined network that you configure and manage through the OCI Console, CLI, or APIs. Unlike physical network hardware, OCI networking is entirely virtual, fully programmable, and deeply integrated with OCI compute, storage, and security services.

This lab series walks through the core components of OCI Networking — from standing up a VCN to troubleshooting live traffic — using step-by-step OCI Console instructions.

---

## Architecture You Will Build

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────┐
│  VCN  10.0.0.0/16                                   │
│                                                      │
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │  Public Subnet       │  │  Private Subnet      │ │
│  │  10.0.1.0/24         │  │  10.0.2.0/24         │ │
│  │                      │  │                      │ │
│  │  [Web VM]            │  │  [App VM]            │ │
│  │  NSG-Web             │  │  NSG-App             │ │
│  └──────────┬───────────┘  └──────────┬───────────┘ │
│             │                         │              │
│    ┌────────┘    Route Tables         └────────┐     │
│    ▼                                           ▼     │
│  [IGW]                                     [NAT GW]  │
│    │                                           │     │
└────┼───────────────────────────────────────────┼─────┘
     │                                           │
   Internet                                   Internet
  (inbound)                                  (outbound only)
```

**Gateways attached to this VCN:**

| Gateway | Purpose |
|---|---|
| Internet Gateway (IGW) | Bidirectional internet access for public subnet resources |
| NAT Gateway | Outbound-only internet for private subnet resources |
| Service Gateway | Private access to Oracle Services (Object Storage, OCI APIs) |

---

## Prerequisites

| Requirement | Notes |
|---|---|
| OCI Tenancy | Free Tier is sufficient for all labs |
| IAM Permissions | `manage virtual-network-family` in the target compartment |
| Compartment | Create or use an existing non-root compartment |
| Region | Any commercial region (e.g. `us-ashburn-1`, `ap-sydney-1`) |

> **Tip:** All labs use the OCI Console UI. No CLI or Terraform required, though equivalent CLI commands are noted where helpful.

---

## Lab Chapters

| # | Chapter | Topic | Time |
|---|---|---|---|
| 01 | [Create VCN & Subnets](./chapters/01-create-vcn-subnets/README.md) | VCN, public subnet, private subnet, DNS | ~10 min |
| 02 | [Attach Gateways](./chapters/02-attach-gateways/README.md) | IGW, NAT GW, Service GW | ~8 min |
| 03 | [Configure Route Tables](./chapters/03-configure-route-tables/README.md) | Public RT, Private RT, route rules | ~8 min |
| 04 | [Apply NSG Rules](./chapters/04-apply-nsg-rules/README.md) | NSG-Web, NSG-App, rule creation | ~10 min |
| 05 | [Run Path Analyzer](./chapters/05-run-path-analyzer/README.md) | Reachability test, DROP analysis | ~12 min |
| 06 | [VCN Flow Logs & Network Command Center](./chapters/06-flow-logs-ncc/README.md) | Flow log setup, topology view, metrics | ~12 min |

---

## Key OCI Networking Concepts

### Virtual Cloud Network (VCN)
A VCN is a customizable, private network in OCI. It lives entirely in software — you define the CIDR block, subnets, route tables, and security rules. Each VCN is scoped to a single OCI region.

- **CIDR range:** RFC-1918 recommended (e.g. `10.0.0.0/16`)
- **Limit:** 50 VCNs per region (soft, raiseable)
- **DNS:** Each VCN gets a DNS label used for internal hostname resolution

### Subnets
Subnets subdivide a VCN's address space. Every compute resource (VM, LB, DB) lives in a subnet.

- **Public subnet:** Resources can have public IPs; traffic routed via IGW
- **Private subnet:** No public IPs; outbound via NAT GW or Service GW
- **Regional scope:** Recommended — spans all Availability Domains in the region
- **Limit:** 300 subnets per VCN

### Gateways

| Gateway | Traffic Direction | Hard Limit |
|---|---|---|
| Internet Gateway (IGW) | Inbound + outbound | 1 per VCN |
| NAT Gateway | Outbound only | 1 per VCN |
| Service Gateway | Oracle Services only | 1 per VCN |
| Dynamic Routing Gateway (DRG) | On-premises / VCN peering | 5 per region |
| Local Peering Gateway (LPG) | VCN-to-VCN (same region) | 10 per VCN |

### Route Tables
Each subnet is associated with exactly one route table. Route rules direct traffic to the appropriate gateway.

- **Max rules:** 200 per route table
- **Max tables:** 300 per VCN (soft default: 10)
- Route rules are evaluated as a longest-prefix match

### Security: Lists vs NSGs

| | Security Lists | Network Security Groups (NSGs) |
|---|---|---|
| Scope | Subnet-wide | Per-VNIC |
| Oracle recommendation | Baseline fallback | ✅ Preferred |
| Max rules | 200 ingress + 200 egress | 120 combined (hard limit) |
| Source/dest | CIDR only | CIDR **or** another NSG |
| VNICs per NSG | N/A | Unlimited (same VCN) |
| NSGs per VNIC | N/A | **5 max (hard limit)** |
| NSGs per VCN | N/A | 1,000 (soft, raiseable) |

### Troubleshooting Tools

| Tool | What it does | Console path |
|---|---|---|
| **Network Command Center** | Topology visualizer + reachability probes | Networking → Network Command Center |
| **Path Analyzer** | Hop-by-hop simulation with DROP reason | Networking → NCC → Path Analyzer |
| **VCN Flow Logs** | Accepted/rejected traffic capture per subnet or VNIC | Logging → Logs → [Enable on subnet] |

---

## Service Limits Reference

| Resource | Limit | Type |
|---|---|---|
| VCNs per region | 50 | Soft |
| Subnets per VCN | 300 | Soft |
| Route rules per table | 200 | Soft |
| Route tables per VCN | 300 | Soft |
| NSGs per VCN | 1,000 | Soft |
| NSGs per VNIC | **5** | **Hard** |
| Rules per NSG | **120** (ingress + egress) | **Hard** |
| IGW per VCN | **1** | **Hard** |
| LPGs per VCN | 10 | Soft |
| DRGs per region | 5 | Soft |

> Soft limits can be increased via **Console → Governance → Limits, Quotas and Usage → Request Limit Increase**

---

## Repository Structure

```
oci-networking-lab/
├── README.md                          ← This file
└── chapters/
    ├── 01-create-vcn-subnets/
    │   └── README.md
    ├── 02-attach-gateways/
    │   └── README.md
    ├── 03-configure-route-tables/
    │   └── README.md
    ├── 04-apply-nsg-rules/
    │   └── README.md
    ├── 05-run-path-analyzer/
    │   └── README.md
    └── 06-flow-logs-ncc/
        └── README.md
```

---

## Additional Resources

- [OCI Networking Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [OCI Service Limits](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm#networking_limits)
- [OCI Architecture Center — Networking](https://docs.oracle.com/solutions/?q=networking&cType=reference-architectures)
- [OCI Path Analyzer](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/path_analyzer.htm)
- [VCN Flow Logs](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/vcn_flow_logs.htm)
- [OCI Network Command Center](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/network_command_center.htm)

---

*Oracle Cloud Infrastructure · Internal Enablement · © 2025 Oracle and/or its affiliates*
