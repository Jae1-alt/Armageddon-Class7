
#### 1. Create VPC

* Dashboard > **Create VPC** (Select "VPC and more").
* **IPv4 CIDR block:** Default or custom (e.g., 10.0.0.0/16).
* **Availability Zones (AZs):** Choose **2** (Required for RDS Subnet Groups).
* **NAT Gateways:** None (Not needed for this lab).
* **VPC Endpoints:** None.
* **DNS options:** Ensure "Enable DNS hostnames" and "Enable DNS resolution" are checked.
* **Create VPC.**

#### 2. Create DB Subnet Group

* RDS Console > **Subnet groups** > **Create DB subnet group**.
* **Name:** `lab-db-subnet-group` (or similar).
* **VPC:** Select the VPC created in Step 1.
* **Add subnets:**
	* Select the **2 AZs** you chose earlier.
	* **Crucial:** Select the two **Private Subnets** created by the VPC wizard (verify the CIDRs to ensure they are the private ones).
* **Create.**

#### 3. Create RDS Database

* RDS Console > **Create database**.
* **Creation method:** Standard Create (Full Configuration).
* **Engine:** MySQL.
* **Template:** Free Tier.
* **Settings:**
	* **DB Instance Identifier:** `lab-mysql`
	* **Master username:** `admin`
	* **Credentials management:** Self-managed. (Create and **save** your password).
* **Connectivity:**
	* **VPC:** Select your created VPC.
	* **DB Subnet Group:** Select the group created in **Step 2** (Do not use Automatic).
	* **Public access:** No.
	* **VPC Security Group:** Select "Create new" and name it `lab-rds-sg`.


* **Create Database.**

#### 4. Create Secret in Secrets Manager

* Secrets Manager Console > **Store a new secret**.
* **Secret type:** Credentials for Amazon RDS database.
* **Input:** User (`admin`) and the Password you created in Step 3.
* **Database:** Select `lab-mysql` from the list.
* **Secret Name:** `rds-secret` (Must match the name used in your application code).
* **Store Secret.**

#### 5. Create IAM Role for EC2

* IAM Console > **Policies** > **Create Policy**.
	* **JSON:** Paste the `secretsmanager:GetSecretValue` JSON provided in your notes.
	* **Name:** `LabSecretPolicy`.
* IAM Console > **Roles** > **Create Role**.
	* **Trusted Entity:** AWS Service > EC2.
	* **Add Permissions:** Search for and select `LabSecretPolicy`.
	* **Name:** `LabEC2Role`.



#### 6. Create EC2 Security Group

* EC2 Console > **Security Groups** > **Create Security Group**.
* **Name:** `lab-web-sg`.
* **VPC:** Select your Lab VPC.
* **Inbound Rules:**
	* Type: **HTTP** | Port: 80 | Source: Anywhere (`0.0.0.0/0`).
	* Type: **SSH** | Port: 22 | Source: My IP.



#### 7. Update RDS Security Group Rules

* Go to the **RDS Security Group** (`lab-rds-sg`) created in Step 3.
* **Edit Inbound rules**:
	* **Type:** MySQL/Aurora (Port 3306).
	* **Source:** Custom > Select the Security Group ID of `lab-web-sg` (created in Step 6).
	* *Remove any other inbound rules.*



#### 8. Launch EC2 Instance

* EC2 Console > **Launch Instance**.
* **Name:** `Lab-Web-Server`.
* **AMI:** Amazon Linux 2023.
* **Instance Type:** t2.micro (Free Tier).
* **Key pair:** Select or create one.
* **Network settings:**
	* **VPC:** Select Lab VPC.
	* **Subnet:** Select a **Public Subnet**.
	* **Auto-assign Public IP:** Enable.
	* **Security groups:** Select existing > `lab-web-sg`.
* **Advanced details (Crucial):**
	* **IAM instance profile:** Select `LabEC2Role`.
	* **User Data:** Paste the `user_data_up.sh` script here.


* **Launch Instance.**

#### 9. Verification

Wait for the instance to pass status checks, then test:

```text
http://<public_ip>
http://<public_ip>/init
http://<public_ip>/add?note=test_note
```