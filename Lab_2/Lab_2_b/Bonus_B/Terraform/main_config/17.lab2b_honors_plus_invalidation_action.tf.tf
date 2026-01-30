# ------------------------------------------------------------------------------
# LAB 2B - HONORS PLUS: INVALIDATION STRATEGY
# ------------------------------------------------------------------------------
# Strategy Selected: Option 1 (Manual / Runbook)
#
# REASONING:
# We do NOT automate invalidations in Terraform for this project because:
# 1. It encourages "Lazy Invalidation" (invalidating on every apply).
# 2. It risks "Thundering Herd" issues if /* is used inadvertently.
# 3. We prefer "Versioning" for static assets (images, JS, CSS).
#
# OPERATIONAL RUNBOOK:
# In the event of a "Break Glass" scenario (e.g., stale index.html), 
# use the AWS CLI commands documented in the Incident Report.
# ------------------------------------------------------------------------------