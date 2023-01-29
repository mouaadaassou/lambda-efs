# CloudWatch:

## Introduction:

Amazon CloudWatch is a monitoring service to monitor the health and performance of your AWS resources,
as well as the application you run on AWS, and in your data center.

What can CloudWatch monitor:

1. Compute:
    * EC2 instances.
    * Auto Scale groups.
    * Elastic Load Balancer.
    * Route 53 health checks.
    * Lambda.
2. Storage and Content Delivery:
    * EBS Volumes.
    * Storage Gateway
    * CloudFront
3. Databases and Analytics:
    * DynamoDB tables.
    * ElasticCache nodes.
    * RDS instances.
    * Redshift.
    * Elastic Map Reduce.
4. Others:
    * SNS topics.
    * SQS queues.
    * API Gateway.
    * Estimated Charges.

## CloudWatch Logs Terminology:
* Log Events: Event message and time stamp.
* Log Stream: Sequence of log events from the same source, e.g. an Apache log from a specific host, 
  Must belong to a log group.
* Log Groups: Group log streams together, centrally managed retention, monitoring 
  and access control settings. No limit on the number of log streams in a log group.

```
Note: We can configure CloudWatch to send notification whenever the rate error exceeds
a threshold you specify.
```

Bt default, CloudWatch logs are kept indefinitely.

## CloudWatch Alarms:
You can create an alarm to monitor any CloudWatch metric in your account.
* Alarms: This can include EC2 CPU utilization, Elastic Load Balancer latency, or even the charges on your AWS bill.
* Threshold: You can set appropriate threshold to trigger the alarms and actions to be taken if an alarm state is reached.
* 