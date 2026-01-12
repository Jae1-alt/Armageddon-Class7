
### 🏗️ Infrastructure Diagram (Lab 1.a)

![](attachment/acd485735477eb686449707aa486a701.png)

The diagram above illustrates the final infrastructure state upon successful completion of Lab 1.a.

**Key Architecture Points:**

- **Public Subnet (App Tier):** The EC2 instance resides here, allowing inbound HTTP traffic (Port 80) from `0.0.0.0/0` (Anywhere).
    
    > **Note:** SSH (Port 22) access is enabled but should be strictly limited to the administrator's specific IP address for security. If using **AWS EC2 Instance Connect** (browser-based SSH), you must allow traffic from the AWS IP range for that service (or use `0.0.0.0/0` temporarily for this lab).
    
- **Secrets Management:** Database login credentials are stored securely in **AWS Secrets Manager**. The EC2 instance retrieves these credentials at runtime via an attached **IAM Role** with a specific permission policy, eliminating the need for hardcoded secrets.
    
- **Private Subnet (Data Tier):** The RDS database resides here. Its Security Group is configured to accept traffic **only on Port 3306** and **only from the EC2 instance's Security Group**. This ensures the database is inaccessible from the public internet.
    

---

## ⚙️ Process Optimizations & Adjustments

While the original deployment walkthrough was functional, I have implemented several strategic adjustments to streamline the workflow, enhance security boundaries, and ensure compatibility with modern Amazon Machine Images (AMIs).

### 1. Deployment Order & Initialization Strategy

I identified two distinct workflows for deploying the application resources. Each has specific trade-offs regarding automation and initialization timing.

#### Option A: EC2 Prioritization (Automated Networking)

In this workflow, I provision the **EC2 Instance** _before_ creating the RDS Database.

- **The Benefit:** This sequence unlocks the _"Connect to an EC2 compute resource"_ feature within the RDS console setup. This automates the network bridging between the compute and data tiers.
    
- **⚠️ Important Trade-off:** Using this automated feature creates two new Security Groups automatically.
    
    > **Note:** If you have already manually created your Security Groups (as done in this lab), using this feature will result in **redundant/duplicate Security Groups**. Use this feature only if you want AWS to handle the security group creation for you.
    

⚠️ The "Cached Failure" Risk:

If the EC2 instance launches before the RDS infrastructure is fully ready, the application will attempt to connect to the database, fail, and cache this failed state in memory. Even if you rectify the underlying resource issues later, visiting http://<public_ip>/init may still fail because the running application process is stuck in its previous "disconnected" state.

Resolution:

To force the application to drop its cached state and re-establish a connection, you must restart the service.

1. **Service Restart (via SSH):** Run `sudo systemctl restart rdsapp`
    
2. **Instance Reboot (Simplest):** Reboot the EC2 instance via the AWS Console to flush the state and re-run initialization.
    

---

#### Option B: Infrastructure-First (Recommended Strategy)

To completely eliminate the "Cached Failure" state and avoid the need for post-deployment reboots, the following workflow is recommended:

**The Workflow:**

1. **Network Prep:** Create the Security Groups for both the Database and the Web Server _first_.
    
2. **Database Provisioning:** Launch the RDS instance and assign it to the DB Security Group.
    
3. **Bridge Configuration:** Edit the **RDS Security Group** inbound rules to explicitly allow traffic on port 3306 from the **Web Server Security Group** ID.
    
4. **Compute Launch:** Once the RDS instance status is "Available," launch the **EC2 instance** (with the updated `user_data` script), attaching the pre-made Web Server Security Group during creation.
    

The Result:

Because the infrastructure is fully operational before the application boot script runs, the EC2 instance establishes a secure connection immediately upon launch. The application successfully initializes the labdb database without manual intervention or restarts.

---

### 2. Manual DB Subnet Group Configuration

I explicitly created a **DB Subnet Group** rather than relying on defaults.

- **Why:** This ensures the RDS instance is placed strictly within our defined private network boundary.
    
- **Result:** It prevents AWS from inadvertently assigning the database to random subnets across Availability Zones that may not align with our architecture.
    

### 3. Amazon Linux 2023 Compatibility (Critical Fix)

The original documentation referenced a `mysql` client installation that is deprecated and incompatible with **Amazon Linux 2023 (AL2023)**. AL2023 has replaced the legacy MySQL client with MariaDB.

#### 📄 User Data Script Updates

To support the application initialization logic, the `user_data.sh` script requires a specific update. The `mariadb105` package acts as a drop-in replacement for the MySQL client.

Required Change:

You must replace the legacy yum install mysql command with the dnf command below. This should be placed within the first 5 lines of your script to ensure dependencies are present before the application attempts to launch.

```bash
dnf install mariadb105 -y
```

> **Note:** Additional code has also been added to the script to capture and display any error messages directly on the webpage if the `http://<public_ip>/init` process fails.

---

## 🔧 Troubleshooting: Manual Database Initialization

If for some reason the application's auto-initialization at `http://<public_ip>/init` fails to create the necessary tables, you must manually initialize the database via the Command Line Interface (CLI).

**Steps to Resolve:**

1. Access the Compute Tier:
    
    Log into your EC2 instance via SSH (or Instance Connect if enabled).
    
2. Connect to the Data Tier:
    
    Use the MariaDB client installed via the User Data script to connect to RDS.
    
    
    ```bash
    mysql -h <RDS_ENDPOINT> -u <USER> -p
    ```
    
    _(Enter your password when prompted)_
    
3. Verify Current State:
    
    Check if the database exists.
    
    
    ```SQL
    SHOW DATABASES;
    ```
    
4. Create the Database:
    
    If labdb is missing, create it manually.
    
    
    ```SQL
    CREATE DATABASE labdb;
    ```
    
5. **Confirm and Exit:**
	
    
    ```sql
    SHOW DATABASES;
    EXIT;
    ```
    
6. Restart the Application:
    
    Force the application service to reconnect to the newly created database context.
    
    
    ```bash
    sudo systemctl restart rdsapp
    ```
    

**Example Success Output:**

![](attachment/c51dd980c7fdf474068a803d0d85f1a8.png)

Verification:

Once these steps are complete, revisit the initialization URL (/init). You should now be able to add and list notes successfully.