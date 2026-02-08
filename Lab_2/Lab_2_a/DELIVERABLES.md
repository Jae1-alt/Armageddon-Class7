
Deliverables for Lab 2a

## 1
- A) Direct ALB access should fail (403):
  >![](attachment/f43d864295ca5015d6d851584ada8f4e.png)

- B) CloudFront access should succeed, both `app.topclick.click` & `topclick.click` succeeding:
  >![](attachment/3cbf7220282f9d77813bdd217af03f4c.png)

## 2
Evidence WAF moved to CloudFront:

- Evidence that the WAF is in the same region as the CloudFront Distribution, and is scoped to be used by CloudFront
  >![](attachment/693ee0c9080f7908dd2f7be92b62c469.png)

- Evidence that the CloudFront Distribution sees itself guarded by the WAF (referencing the WAF):
  >![](attachment/34243394df162ddc561a55fab3c89bdb.png)

## 3
- Both Domain Names point to Cloudfront, using the `dig <domain_name> A +short` command :
  >![](attachment/8355e89f5860160eedb2099e5cb3fc08.png)