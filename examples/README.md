# EC2 Module – Examples

This directory contains two example configurations demonstrating common usage patterns.

---

## Example 1: Standard x86_64 Instance (Amazon Linux 2023)

Deploys a `t3.medium` instance with:
- New RSA 4096-bit key pair
- New security group: SSH from RFC-1918, HTTP/HTTPS from anywhere
- Encrypted gp3 root volume (30 GiB, 3000 IOPS, 125 MiB/s)
- Additional encrypted gp3 data volume (100 GiB) that persists after termination
- Hyperthreading disabled (`cpu_threads_per_core = 1`)
- Termination protection enabled
- IMDSv2 enforced, instance tags exposed via IMDS
- Detailed CloudWatch monitoring

## Example 2: Graviton arm64 Instance (Ubuntu 22.04)

Deploys a `t4g.medium` instance with:
- Existing key pair and existing security groups
- Encrypted gp3 root volume (20 GiB, 3000 IOPS, 125 MiB/s)
- IMDSv2 enforced
- Detailed CloudWatch monitoring

---

## Prerequisites

| Requirement | Version |
|-------------|---------|
| Terraform | >= 1.5.0 |
| AWS Provider | >= 5.0.0 |

---

## Required Inputs

| Name | Description |
|------|-------------|
| `subnet_id` | Subnet ID in which to launch the instances |
| `vpc_id` | VPC ID for the security group (Example 1) |

## Optional Inputs

| Name | Default | Description |
|------|---------|-------------|
| `aws_region` | `"us-east-1"` | AWS region to deploy into |
| `existing_key_pair_name` | `null` | Existing key pair name for the Graviton example |
| `existing_security_group_ids` | `[]` | Existing SG IDs for the Graviton example |

---

## Steps to Run

```bash
cd examples/
terraform init
terraform plan \
  -var="subnet_id=subnet-xxxx" \
  -var="vpc_id=vpc-xxxx"
terraform apply \
  -var="subnet_id=subnet-xxxx" \
  -var="vpc_id=vpc-xxxx"
terraform destroy \
  -var="subnet_id=subnet-xxxx" \
  -var="vpc_id=vpc-xxxx"
```

---

## Outputs

| Name | Description |
|------|-------------|
| `standard_instance_id` | Instance ID of the x86_64 example |
| `standard_private_ip` | Private IP of the x86_64 example |
| `standard_architecture` | Architecture of the x86_64 example |
| `graviton_instance_id` | Instance ID of the Graviton example |
| `graviton_architecture` | Architecture of the Graviton example |
