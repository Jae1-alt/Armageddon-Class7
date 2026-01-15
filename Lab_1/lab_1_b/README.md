
# README: Lab 1b - Incident Response & Operational Hardening

## 📌 Overview

This repository contains the documentation and deliverables for **Lab 1b**, focusing on transitioning a monolithic database configuration into a tiered, secure architecture and executing a professional incident response drill.

> Scenario: "Anyone can deploy. Professionals recover."
> 
> This lab simulates an on-call rotation where the production database has become unavailable. My objective was to observe, diagnose, and recover the system without redeploying infrastructure or guessing the root cause.

---

## 📂 Documentation Structure

The documentation is organized into four distinct sections:

### **1: Architectural Evolution (1a → 1b)**

Outlines the initial hardening steps taken to prepare the environment.

- **Key Actions:** Establishing the SNS Alerting pipeline, implementing the "Split-Storage Strategy" (SSM Parameter Store vs. Secrets Manager), and refactoring application code for dual-source retrieval.
    

### **2: Mandatory Incident Runbook (Deliverable)**

The core operational document. It follows a strict, evidence-based remediation process for a **Network Isolation** failure.

- **Process:** Acknowledge → Observe (Logs) → Validate (SSM/SM) → Contain → Recover → Post-Incident Validation.
    

### **3: Incident Response Report (Deliverable)**

A high-level executive summary of the recovery efforts.

- **Metrics:** Calculated **Time to Recovery (TTR)** by correlating UTC CloudWatch logs with local EST timestamps.
    
- **Analysis:** Root cause identification and timeline.
    

### **4: Operations & Incident Reflections (Deliverable)**

A critical look at the operational maturity of the system.

- **Preventive Actions:** Strategy for reducing MTTR and preventing recurrence through **Infrastructure as Code (IaC)** and automated drift detection.
    

---

## 🛠 Key Skills Demonstrated

- **Observability:** Configuring CloudWatch Alarms and Custom Metrics.
    
- **Log Analysis:** Querying AWS CloudWatch Logs via CLI to identify specific error signatures (Error 2003 vs. 1045).
    
- **Security & IAM:** Implementing "Least Privilege" for EC2 Instance Profiles and managing sensitive data via Secrets Manager.
    
- **Incident Management:** Following an industry-standard Runbook to resolve production issues under pressure.
    

---

## 🚀 How to Navigate

- Detailed screenshots of the AWS Console and CLI outputs are embedded within each section.
	
- Parts 2, 3, and 4 are parts of the deliverables and are within the 'Deliverables' directory.
	
- The refactored application logic can be found in the provided `user_data_prop.sh` file.
    

---
---