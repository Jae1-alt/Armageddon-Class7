
### Lab1c Bonus F - CloudWatch Logs Insights to add to Runbook

After numerous successful connections and purposeful wrong connections, CloudWatch Log insights consults; running commands to hits to the domain names ('app.topclick.click' and 'topclick.click'):
  >![](attachment/fef0d36622297c8395328fafa9eb3092.png)

Showing top client's IP address (the administrators IP was `74.244.163.116`):
  >![](attachment/db6731fde66bfecd6fb09ce318164cf9.png)

Showing the URL's the hits are trying to reach:
  >![](attachment/15a4bf349f8c7fd290b5a245e0ea03cb.png)
  >![](attachment/5513ae46f7bb3b6c5e440be7a6497f2e.png)

Evidence of which WAF rule is doing the blocking:
  >![](attachment/4cd313339a24121a2fb62cec68c1bea0.png)

Rate of blocks over time:
  >![](attachment/c7d4a1e13ae18a06928791d479ca8689.png)
  >![](attachment/0c5fbc2f77ce3d100786c43d0eec18fe.png)

Showcasing hits per country. Note that the admin is in Jamaica (JM). Other countries are bad actors maybe?!
  >![](attachment/0d173dd5e4bdb17a40162f971f43acc2.png)

---

**Before the following logs were retrieved, the inbound security group rule was disabled to simulate and incident.**

Count of errors over time:
  >![](attachment/e79103a0faed4c26b60611d6091a5ec8.png)


Showing the most recent Database failures:
  >![](attachment/e92695cfa0dee0c08b3a3f8bf4ae1662.png)


Retrieving the details if the logs; filtering the logs by specific error types. These showcase the retrieval of the 'time out' error logs; which is accurate given that the issue created was a security group failure.
  >![](attachment/7ac52ae597f1ec7d8e00c2095cd79b36.png)
  





