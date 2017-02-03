# Unattended CISProwler

Based on [Alfresco Prowler: AWS CIS Benchmark Tool](https://github.com/Alfresco/aws-cis-security-benchmark), but customised to run unattended.

`v1.0` - This is a cloudformation template that creates an ASG with a single instance which downloads and runs the prowler script against the account it's running in. An S3 bucket is created (if not existing already) and the script output is copied there, timestamped filename.

`v1.1` - Fixing [permissions issue](https://github.com/yurasuka/aws-cis-prowler/issues/3).

The bootstrapping ends with the ASGs DesiredCount being set to 0, which terminates the instance. You can set a schedule to set the DesiredCount to 1 e.g. weekly.

It also creates a CloudWatch logs group for VPC Flowlogs. This is probably overkill and I might remove it. _I might add CloudWatch logs for syslogs anyway to have some sort of auditability._

If using OS X or Linux, you could just launch the stack via the CLI following the output of the `launchCISProwler.sh` script (v1.0 just echos the commands to run)
