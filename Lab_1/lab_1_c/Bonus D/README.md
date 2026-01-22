
### Bonus D: Zone Apex Routing & High-Fidelity Observability

This lab finalizes the production-grade architecture by enabling root domain access and implementing a comprehensive logging strategy. While the previous setup secured the subdomain (`app.topclick.click`), a robust architecture must also handle traffic at the "Zone Apex" (the root `topclick.click`) and retain long-term traffic data for auditing.

To achieve this, I upgraded the SSL/TLS certificate to support **Subject Alternative Names (SANs)**, configured **Route 53 Alias Records** to handle root domain routing, and deployed a secure S3 bucket to act as a "Flight Recorder" for all ALB traffic. **AWS WAF (v2)** was also implemented to act as an active perimeter defense for the application.


### Verification Commands and Results

- Verifying Apex record exists:
  >![](attachment/1de79329c309dd0868585331f5fd3e32.png)
  
  - Verifying ALB logging is enabled:
  >![](attachment/2dac7e032442338d55fcb6a3c35861da.png)
- ALB Attributes:
  >![](attachment/32a985b77658e3f2ccc68114fdd7bb99.png)
  
- Domain names active and reachable:
  >![](attachment/7ee4e7a43382d4314060acd744a664b7.png)
  
- Evidence of logs in S3 bucket:
  >![](attachment/4cf3028415d09be756a025baf27b011b.png)
  
- Evidence of the 'app' + domain and the root domain working in web browser:
  >![](attachment/296754291d383a4c39937c1647c258a4.png)