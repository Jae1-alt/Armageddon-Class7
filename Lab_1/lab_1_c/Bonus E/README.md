
While WAF protects the site, simply "blocking" traffic isn't enough for a production environment. We need to know **who** was blocked, **which** specific rule they triggered, and **what** their intent was.

In this section, I implemented a flexible logging architecture that allows us to choose between three industry-standard destinations (CloudWatch, S3, or Kinesis Firehose). For this specific build, I chose **CloudWatch Logs** to enable real-time searching and rapid incident response.

By implementing this logging strategy, we have moved the infrastructure from a "Passive" state to an "Active" state. We no longer hope the WAF is working; we have the verifiable JSON evidence to prove it.


### Verification Commands and Results:

- Confirmation that WAF Logging is enabled:
  >![](attachment/a1b8001a674959c73eff313978230056.png)
  
  - Generating traffic for the website:
  >![](attachment/5566a97a31b6bbb2de2ccd017b55a191.png)
  
  - Describing CloudWatch Log Streams
  >![](attachment/a2d4cf636fc3a50624d45499d6b1319d.png)
  
  - Retrieving and Filtering recent log events to newest 20:
  >![](attachment/86187e899408618a4b516c7b81ff8b21.png)![](attachment/16c0f442c940195f9445a57c86459aaf.png) 