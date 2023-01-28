# Elastic Filesystem:

## Advanced EFS:
### Throughput Modes:
An EFS file system can support many thousands of simultaneous connections.
1. Bursting: The default mode, scales as your filesystem grows. Supports periodic bursting to cater for peaks.
2. Provisioned Throughput: Optionally define the throughput that you want. For applications that consistently need high performance.

```
Note: Throughput is measured in mebibytes per second - MiB/s => 1 Mib = 1.048576MB
```

## Enabling Lambda to access VPC Resources:
To enable this, you need to allow the function to connect to the private subnet.
Lambda needs the following VPC configuration information so that it can connect to the VPC:
* Private Subnet Id
* Security Group Id (with required access)
Lambda uses this information to set up ENIs using an available IP address from your private subnet.

