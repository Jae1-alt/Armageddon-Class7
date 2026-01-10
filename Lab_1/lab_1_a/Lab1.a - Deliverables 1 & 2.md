
## Screenshots
### a. Screenshot of RDS SG inbound rule using source = ec2-lab-sg

This inbound rule only inbound traffic access only from the security group ec2-lab-sg on port 3306.

![](attachment/144115003f1f130589fd40131d39aa39.png)

![](attachment/a38f976b6a4e6cf525fdc1cc9afdbde6.png)

"ec2-lab-sg" information:
![](attachment/d3e095c6fe5fe560025baa79bcd34c14.png)
The security group rule only allows inbound HTTP (Port 80) traffic access from IPv4 everywhere (0.0.0.0/0) and SHH (port 22) traffic from the Jaune's specific public IP address (at the time of the lab).

---

### b. Screenshot of EC2 Role Attached

![](attachment/53444f40fa827adc99c2d8e7072cad03.png)

---
### c. Screenshot of '/list' output showing at least 3 notes

![](attachment/3cb2a065135d42f3cebd7599e83339cd.png)

---
---

## Short answers:

### a. Why is DB inbound source restricted to the EC2 security group?

- This use of security group referencing was done, adhering to the principle least privilege, to ensure that access to the database is only granted to the assign instance. Additionally EC2 instances are ephemeral, thus if n instance dies and replaced it will have a new IP. So relying on the IP to restrict access is far less reliable. Also setting the assigning the entire subnet access to the DB also comes with risks, as in this situation, and resource that can enter the subnet (malicious or not) can then reach the database. Thus using the dedicated EC2's security group will handle dynamic IP changes while also adhering to the principle of least privilege.

### b.  What port does MySQL use?

- MySQL uses port **3306**

### c. Why is Secrets Manager better than storing creds in code/user-data?

- The code for the application and the user data is readable, plain text, so hardcoding the credentials for the database in them creates a high risk vulnerability. In this situation, should someone gain access to the instance or the source code for the application, they would then have the username and password needed to log into the database.
  Additionally secrets manager provides:
	- encryption for the secrets it stores
	- configurable rotation for secrets
	- the ability for the application to only get the key when needed


## Additional answers:

- If the security group rules where removed then the instance and the RDS database would have know rules governing access to them, and they would default to denying access. 
- If the RDS database (DB) had its rules removed, the EC2 instance could not communicate with the DB and if you tried to initialize, add or retrieve information using the app's website you would get a "Internal Server" error. 
- If you removed the security group rules on the EC2, when you tried to access the instance's public IP, the would continually try to load with no success.

- Broader access to the DB or Secrets Manager violates the Principle of Least Privilege. Granting more access than is needed for the scope of the operation increases the potential blast radius and damage, should the resource be compromised by bad actors or become defective.

- The roles used in this lab exists to grant permission to the EC2 instance, it is attached to, to be able to retrieve the secrets stored in Secret's Manager. These Secret's are referenced by the application code, and are the credentials needed to access the RDS DB.

- When a role is attached to a resource, the resource's permissions are defined exclusively by the policies attached to that role. The resource can only perform actions explicitly allowed by the role; all other actions are implicitly denied.