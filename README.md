# Deploy EC2 Instance with Security Group using Terraform

This Terraform configuration provisions an EC2 instance and a security group resource on AWS.

## Overview

![EC2 Instance with Security Group](ec2-security-group-overview.png)

The architecture sets up a single EC2 instance with a security group allowing inbound traffic on port 80 (HTTP) and port 22 (SSH).

## Prerequisites

- [AWS Account](https://aws.amazon.com/account/) with proper permissions to create resources
- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine

## Usage

1. Clone this repository
2. Navigate to the project directory
3. Run `terraform init` to initialize the Terraform working directory
4. Review the `main.tf` file and modify the variables according to your requirements
5. Run `terraform plan` to see the execution plan
6. Run `terraform apply` to provision the resources
7. Once the apply is complete, it will output the public IP address of the EC2 instance

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS region to create resources in | `string` | `us-east-1` | no |
| instance_type | The EC2 instance type | `string` | `t2.micro` | no |
| ami | The AMI ID for the EC2 instance | `string` | `ami-0cff7528ff583bf9a` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_public_ip | The public IP address of the EC2 instance |

## Cleanup

To remove all resources created by this configuration, run: `terraform destroy`
