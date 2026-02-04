# Architecture Audit Summary
**Project:** Project Armageddon (Secure Data Residency)
**Date:** February 3, 2026
**Auditor Identity:** Jaune Alcide

## 1. Data Residency Compliance (APPI / GDPR)
* **Database Location:** Tokyo Region (ap-northeast-1) ONLY.
* **Evidence:** Validated via AWS CLI; no RDS instances exist in São Paulo.
* **Constraint:** The physical distance ensures data never leaves Japanese legal jurisdiction at rest.

## 2. Network Sovereignty
* **Transit Gateway (TGW):** Establishes a private, encrypted corridor between Tokyo (Hub) and São Paulo (Spoke).
* **Traffic Flow:** User -> CloudFront -> ALB (SP) -> TGW -> ALB (Tokyo) -> App -> RDS.
* **Isolation:** No public internet routing exists between the Database and the outside world; all access is mediated by the application layer.

## 3. Edge Security
* **WAF Enforced:** AWS Managed Rules (Common Rule Set) block SQLi and XSS attacks at the edge.
* **Logging:** All edge traffic is immutably logged to the Tokyo S3 Audit Vault for forensic analysis.

