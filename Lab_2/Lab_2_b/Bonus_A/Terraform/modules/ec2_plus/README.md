
# AWS EC2 Plus Module

A flexible, reusable Terraform module for provisioning EC2 instances on AWS. This module supports both **Linux** and **Windows** workloads, handles optional SSH key generation, dynamic Security Groups, and user data script execution.

## Features

* **OS Agnostic:** Works for Linux (SSH) and Windows (RDP).
* **Scalable:** Supports creating 1 or N instances via `instance_count`.
* **Smart Networking:** Creates a dedicated Security Group with dynamic rules and accepts additional existing Security Groups.
* **Key Management:** Can generate a new SSH key pair or use an existing AWS Key Pair.
* **Bootstrapping:** Supports User Data scripts (bash/powershell) loaded relative to the root module path.

## Usage Examples

### 1. Basic Linux Web Server

```hcl
module "web_server" {
  source = "./modules/ec2_plus"

  instance_name     = "web-server"
  instance_count    = 2
  instance_type     = "t3.micro"
  subnet_id         = "subnet-12345678"
  
  # Networking
  public_ip_address = true
  ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow HTTP"
    }
  }

  # Scripting (Located in your project root)
  user_script = "scripts/install_nginx.sh"
}

```

### 2. Windows Server with Auto-Decryption

```hcl
module "windows_db" {
  source = "./modules/ec2_plus"

  instance_name     = "win-db"
  instance_count    = 1
  ami_id            = "ami-0abcdef123456" # Windows AMI ID
  
  # Key Management
  key_needed        = true   # Module generates a key
  key_name          = "win-key-auth"
  
  # Windows Specifics
  get_password_data = true   # Required for password retrieval
  
  ingress_rules = {
    rdp = {
      from_port   = 3389
      to_port     = 3389
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/8" # Internal Access Only
      description = "RDP Access"
    }
  }
}

```

## Provider Requirements

| Name | Version |
| --- | --- |
| `terraform` | `>= 1.0.0` |
| `aws` | `>= 4.0` |
| `tls` | `>= 2.5` |

## Resources Created

| Resource | Description |
| --- | --- |
| `aws_instance` | The main EC2 instance(s). |
| `aws_security_group` | A dedicated security group attached to the instance. |
| `aws_vpc_security_group_ingress_rule` | Dynamic ingress rules based on `create_sg` and `ingress_rules` input variables. Resource generates if `var.create_sg` is `true`. |
|`aws_vpc_security_group_ingress_rule`|Dynamic ingress rules based on `create_sg` and `egress_rules` input variables. Resource generates if `var.create_sg` is `true` .|
| `tls_private_key` | (Optional) Generates an RSA private key if `key_needed = true`. |
| `aws_key_pair` | (Optional) Registers the generated key with AWS if `key_needed = true`. |

***

## **Input Variables**

### **Common / Metadata**
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `environment` | `string` | `"test"` | Environment tag for resources (e.g., dev, prod). |
| `owner` | `string` | `"Jae"` | Owner tag for the created resources. |
| `tags` | `map(string)` | `{}` | Additional custom tags to apply to all resources. |
### **EC2 Configuration**
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `instance_name` | `string` | `""` | The Name tag for the instance (will have index appended). |
| `instance_count` | `number` | `1` | The number of instances to create. |
| `instance_type` | `string` | t3.micro | The EC2 instance type (e.g., `t2.micro`). |
| `ami_id` | `string` | `null` | Specific AMI ID. If `null`, module uses `ami_filters` to look one up. |
| `ami_filters` | `map(list(string))` | *Amazon Linux 2023* | Map of filters for the `aws_ami` data source if `ami_id` is not provided. |
| `user_script` | `string` | `null` | Path to a user data script file (relative to root). |
| `get_password` | `bool` | `false` | Set `true` to retrieve encrypted password (required for Windows RDP). |
### **Networking**
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `vpc_id` | `string` | `null` | The VPC ID where the Security Group will be created. |
| `subnet_id` | `string` | `null` | The Subnet ID where the instance will be launched. |
| `public_ip_address` | `bool` | `false` | Whether to assign a public IP address to the instance. |
### **Security Groups**
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `create_sg` | `bool` | `true` | Controls if a new Security Group is created for the instance. |
| `sg_name` | `string` | `"Wrong"` | Name of the Security Group to create. |
| `sg_description` | `string` | `null` | Description for the Security Group. |
| `ingress_rules` | `map(object)` | *HTTP (80)* | **Complex.** See "Security Group Rules Configuration" section below. |
| `egress_rules` | `map(object)` | *All Traffic* | **Complex.** See "Security Group Rules Configuration" section below. |
| `additional_security_group_ids` | `list(string)` | `[]` | List of existing Security Group IDs to attach alongside the created one. |
### **Keys & Access** 
| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `key_needed` | `bool` | `false` | Set to `true` to have the module generate a new SSH key pair. |
| `key_name` | `string` | `null` | Name of the Key Pair to use (or the name for the new key if creating one). |

### Security Group Rules Configuration

The `ingress_rules` and `egress_rules` variables use a **Map of Objects** structure. This allows you to define multiple named rules in a single block.

**Strict Structure Requirement:**
Every rule must include the following 5 keys:

1. **Map Key** (e.g., `"http"`): An arbitrary name for the rule (used for Terraform state tracking).
2. **`from_port`** (number): Start of the port range.
3. **`to_port`** (number): End of the port range.
4. **`ip_protocol`** (string): Protocol to allow (`"tcp"`, `"udp"`, `"icmp"`, or `"-1"` for all).
5. **`cidr_ipv4`** (string): The source CIDR block (e.g., `"0.0.0.0/0"`).
6. **`description`** (optional string): Note about the rule.

#### Example 1: Standard Web Server (Ingress)

```hcl
ingress_rules = {
  # Rule 1: Allow HTTP from anywhere
  "http" = {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow global HTTP access"
  }
  
  # Rule 2: Allow HTTPS from anywhere
  "https" = {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow global HTTPS access"
  }
}

```

#### Example 2: Strict Internal Database (Ingress)

```hcl
ingress_rules = {
  "mysql_internal" = {
    from_port   = 3306
    to_port     = 3306
    ip_protocol = "tcp"
    cidr_ipv4   = "10.0.0.0/16" # Only allow traffic from inside VPC
    description = "Internal MySQL Access"
  }
}

```

#### Example 3: Default Egress (Allow All)

*The module defaults to this, but if you need to override it:*

```hcl
egress_rules = {
  "allow_all_outbound" = {
    from_port   = 0
    to_port     = 0
    ip_protocol = "-1"        # -1 represents all protocols
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }
}

```

### **EC2 Variable Details**

**`ami_filters` Default Value:**
The module defaults to searching for the latest Amazon Linux 2023 image:

```hcl
{
  name = ["al2023-ami-2023.*-kernel-*-x86_64"]
}

```


## **Outputs**

| Name | Description |
| --- | --- |
| `instance_ids` | A list of IDs for all instances created. |
| `instance_arns` | A list of Amazon Resource Names (ARNs) for all instances created. |
| `instance_public_ips` | A list of Public IP addresses assigned to the instances (if `public_ip_address = true`). |
| `instance_private_ips` | A list of Private IP addresses assigned to the instances. |
| `instance_public_dns` | A list of Public DNS names assigned to the instances. |
| `instance_private_dns` | A list of Private DNS names assigned to the instances. |
| `windows_passwords_decrypted` | A list of **decrypted** Administrator passwords. <br>

<br>Returns `null` if the module did not create the key (`key_needed = false`). |

> **Note on Outputs:**
> Since this module supports scaling via `instance_count`, all outputs are returned as **Lists**, even if you only create 1 instance.
> * **To access the first instance's IP:** `module.ec2.instance_public_ips[0]`
> * **To loop through all IPs:** Use a `for` loop in your root module.
> 
> 

---
## Important Notes

### 1. User Data Script Location

This module uses `${path.root}` to locate your user data script. This means you should provide the path relative to your **root module** (where you run `terraform apply`), not relative to the module file itself.

* **Correct:** `scripts/install.sh`
* **Incorrect:** `../../scripts/install.sh`

### 2. Windows Password Decryption

The output `windows_passwords_decrypted` uses the `rsadecrypt()` function.

* **Requirement:** This only works if `key_needed = true`. If you provide your own pre-existing AWS Key, Terraform cannot decrypt the password because it does not possess the Private Key.
* **Security Warning:** The decrypted password will be stored in your `terraform.tfstate` file in plain text. Ensure your state file is stored securely (e.g., S3 with encryption).

### 3. Security Groups

The instance will effectively have **two** layers of Security Groups:

1. The one created by this module (defined by `var.ingress_rules`).
2. Any existing groups you pass in via `var.additional_security_group_ids`.
These are merged using the `concat()` function in the `aws_instance` resource.

---
