# CIS Benchmarks
## CIS AWS Foundations Benchmark
[AWS Security Blog - Announcing Industry Best Practices for Securing AWS Resources](https://aws.amazon.com/blogs/security/tag/cis-aws-foundations-benchmark/)

### Alfresco Prowler: AWS CIS Benchmark Tool
[Alfresco Prowler: AWS CIS Benchmark Tool](https://d0.awsstatic.com/whitepapers/compliance/AWS_CIS_Foundations_Benchmark.pdf)
Tool based on AWS-CLI commands for AWS account hardening, following guidelines of the CIS Amazon Web Services Foundations Benchmark (https://d0.awsstatic.com/whitepapers/compliance/AWS_CIS_Foundations_Benchmark.pdf)

## CIS AWS Linux Benchmark
[CIS_Amazon_Linux_Benchmark_v2.0.0.pdf](CIS_Amazon_Linux_Benchmark_v2.0.0.pdf)

## CIS AWS Three Tier Web Architecture Benchmark
[CIS_Amazon_Web_Services_Three-tier_Web_Architecture_Benchmark_v1.0.0.pdf](CIS_Amazon_Web_Services_Three-tier_Web_Architecture_Benchmark_v1.0.0.pdf)

# CloudFormation stack
## Summary
Create a self-contained CloudFormation stack which can run the Alfresco Prowler tool against the account it is launched in. It should be launched onto a [CIS hardened AWS](https://aws.amazon.com/marketplace/pp/B01K5UBMTW?qid=1484167707481&sr=0-7&ref_=srh_res_product_title) instance which will output the scan results into a pre-configured S3 bucket.

## Plan
We need a CloudFormation stack with something like this:

### Parameters: 
(all prepopulated except StackOwner):

- Bucket name
 - Pre-configured bucket for CIS Prowler output (in security account) 
 - with bucket policy restricting write to IAM Instance role in this stack and Read to …?
 - bucket lifecycle?

- Git repo for [latest Alfresco Prowler download](https://github.com/Alfresco/aws-cis-security-benchmark), 
 - or if customized - somewhere else (s3?)

- VPC/Subnet IP (e.g. 192.168.168.192/28) (make subnet IP same, i.e. the smallest /28)

- ASG Schedule (cron syntax):
 - Start - 
 - Stop - 

- SSH Key
 - (no SSH key after testing successfully - comment out in yaml)

### Resources:

- IAM Role (rolename match in bucket policy)
- IAM Policy:
 - S3 write to ```!Sub ${BUCKETNAME}``` (bucket in Sec account);
 - IAM ```list-account-aliases``` for resource ```!Sub ${AWS::AccountId}```
 - Modify ```!Ref ASG desiredCount```

- VPC

- 1 subnet (public) same IP as VPC

- IGW
 - route 0.0.0.0 via IGW

- 1 ACL
 - any out

- 1 SG 
 - 80+443 out

- AutoScaling Config
 - CIS AWS Linux (ami-f52f7286)
 - t2.micro with minimum storage
 - public IP true
 - User data

- User data
```
yum -yqq update
yum -yqq install jq (if not already installed)
git clone https://github.com/Alfresco/aws-cis-security-benchmark (use ref?)
# will it work with IAM role? should do - the prowler script uses normal AWS cli
./prowler …. > CISProwler.log / error output to error log? (initial run immediately, subsequent runs at scheduled interval (ASG))
export BUCKETNAME=!ref parameter?
export TIMESTAMP=$(date +"%Y%m%d%H%M”)
export ACCOUNTID=$(aws iam list-account-aliases | jq -r ".AccountAliases[]”) 
# OR use metadata? (curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".accountId”)
# (latter gives ID not alias, former needs IAM permissions to list-account-aliases; alias is easier to identify)
export S3FILENAME=CISProwler-$ACCOUNTID-$TIMESTAMP.log
aws s3 cp CISProwler.log s3://$BUCKETNAME/$S3FILENAME
aws autosclaing set ASG desiredCount to 0 # (i.e. kill self)
```

- AutoScaling Group
 - with max count 1 min count 0 desired count 1
 - ASG Schedule:
  - DesiredCount 1 @ e.g. 2AM Sundays, 
  - DesiredCount 0 at 2:45 AM Sundays 
  - (min charge = 1 hour anyway)

 - Ref start and stop parameters?
 - Tagging at launch: yes

- Outputs/Exports
 - Name: CIS Prowler
 - Owner: Ref Owner

etc!
