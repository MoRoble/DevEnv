## About this code
You can access this Windows server remotely using your local vs-code ssh connection.

Currently, this server is installed with terraform, choco, docker engine that enables you to develop your own image and push it to the repository of your choice.

### what will be deployed
we have used Stockholm - Sweden as our deployment region which is where `t3.micro` instance type is in free tier
1. region used is Stockholm `eu-north-1`
1. instance type is `t3.micro
1. whith this Windows EC2:
    i. AWS CLI
    i. Terraform
    i. choco