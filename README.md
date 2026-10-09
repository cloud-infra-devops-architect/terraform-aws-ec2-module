# 🖥️ terraform-aws-ec2-module

A reusable, production-ready Terraform module for provisioning AWS EC2 instances with flexible AMI selection, key pair management, security groups, and EBS volume configuration.

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud ☁️                                    │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC 🌐                                        │  │
│  │                                                                      │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                    Subnet (Public / Private) 🔲                │  │  │
│  │  │                                                               │  │  │
│  │  │   ┌─────────────────────────────────────────────────────┐    │  │  │
│  │  │   │           🔒 Security Group                          │    │  │  │
│  │  │   │   Ingress Rules (SSH/HTTP/HTTPS/Custom)              │    │  │  │
│  │  │   │   Egress Rules  (All / Custom)                       │    │  │  │
│  │  │   │                                                      │    │  │  │
│  │  │   │   ┌──────────────────────────────────────────────┐  │    │  │  │
│  │  │   │   │           🖥️  EC2 Instance                    │  │    │  │  │
│  │  │   │   │                                              │  │    │  │  │
│  │  │   │   │  OS: Amazon Linux / Ubuntu / RHEL /          │  │    │  │  │
│  │  │   │   │      Debian / Windows                        │  │    │  │  │
│  │  │   │   │  Arch: x86_64 / arm64 (Graviton)             │  │    │  │  │
│  │  │   │   │  Type: t3 / t4g / m6i / c6i / r6i …         │  │    │  │  │
│  │  │   │   │  Tenancy: default / dedicated / host         │  │    │  │  │
│  │  │   │   │  IMDSv2: required ✅                          │  │    │  │  │
│  │  │   │   │  Monitoring: CloudWatch 📊                    │  │    │  │  │
│  │  │   │   │                                              │  │    │  │  │
│  │  │   │   │  ┌────────────────────────────────────────┐  │  │    │  │  │
│  │  │   │   │  │  💾 Root EBS Volume                     │  │  │    │  │  │
│  │  │   │   │  │  Type: gp3 / gp2 / io1 / io2           │  │  │    │  │  │
│  │  │   │   │  │  Encrypted 🔐 (KMS)                     │  │  │    │  │  │
│  │  │   │   │  └────────────────────────────────────────┘  │  │    │  │  │
│  │  │   │   │                                              │  │    │  │  │
│  │  │   │   │  ┌────────────────────────────────────────┐  │  │    │  │  │
│  │  │   │   │  │  💾 Additional EBS Volume(s)            │  │  │    │  │  │
│  │  │   │   │  │  Type: gp3 / io1 / io2 / sc1 / st1     │  │  │    │  │  │
│  │  │   │   │  │  Encrypted 🔐 (KMS)                     │  │  │    │  │  │
│  │  │   │   │  └────────────────────────────────────────┘  │  │    │  │  │
│  │  │   │   └──────────────────────────────────────────────┘  │    │  │  │
│  │  │   └─────────────────────────────────────────────────────┘    │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│   🔑 AWS Key Pair ──────────────────────────────────────────────────────   │
│      (Existing or auto-generated RSA/ED25519)                               │
│                                                                             │
│   👤 IAM Instance Profile ─────────────────────────────────────────────   │
│      (Optional – attach existing profile)                                   │
│                                                                             │
│   📊 Amazon CloudWatch ────────────────────────────────────────────────   │
│      (Detailed monitoring when enabled)                                     │
│                                                                             │
│   🔐 AWS KMS ──────────────────────────────────────────────────────────   │
│      (Optional CMK for EBS encryption)                                      │
└─────────────────────────────────────────────────────────────────────────────┘

  Data Flow:
  Developer 👨💻 ──► Terraform ──► AWS API ──► EC2 Instance 🖥️
                                          ├──► EBS Volumes 💾
                                          ├──► Security Group 🔒
                                          ├──► Key Pair 🔑
                                          └──► CloudWatch 📊
```

---

## ✅ Features

- 🖥️ Flexible instance type selection with validation
- 🏠 Tenancy support: `default`, `dedicated`, `host`
- 🐧 Auto-selects latest AMI for: Amazon Linux 2, Amazon Linux 2023, Ubuntu 20.04/22.04/24.04, RHEL 8/9, Debian 12, Windows Server 2019/2022/2022 Core
- 🔀 Multi-architecture support: `x86_64` and `arm64` (Graviton) with auto-detection from instance family
- 🔑 Create new RSA/ED25519 key pair or use an existing one
- 🔒 Create a new security group with custom ingress/egress rules or attach existing ones
- 💾 Configurable root EBS volume (type, size, IOPS, throughput, encryption)
- 💾 Multiple additional EBS volumes with per-volume configuration
- 🛡️ IMDSv2 enforced by default
- 📊 Detailed CloudWatch monitoring
- 🔐 EBS encryption with optional KMS CMK
- ⚙️ CPU options: core count, hyperthreading, AMD SEV-SNP
- 🔒 Termination and stop protection
- 💤 Hibernation support
- 🏗️ Placement group and Dedicated Host support
- 🔌 Pre-existing ENI attachment (primary and secondary)
- 🚀 Launch template integration
- 🔒 Nitro Enclave support
- 📋 Capacity reservation targeting

---

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |
| tls | >= 4.0.0 |

---

## 🔴 Mandatory Inputs

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name tag for the instance and related resources |
| `instance_type` | `string` | EC2 instance type (e.g. `t3.micro`, `t4g.medium`) |

---

## 🟡 Optional Inputs

### Instance

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `subnet_id` | `string` | `null` | Subnet ID in which to launch the instance |
| `availability_zone` | `string` | `null` | Availability zone; AWS selects when null |
| `tenancy` | `string` | `"default"` | Instance tenancy: `default`, `dedicated`, or `host` |
| `instance_architecture` | `string` | `null` | CPU architecture: `x86_64` or `arm64`; auto-detected when null |

### AMI / OS

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `os_type` | `string` | `"amazon_linux_2023"` | OS for auto AMI selection. Supported: `amazon_linux_2`, `amazon_linux_2023`, `ubuntu_24_04`, `ubuntu_22_04`, `ubuntu_20_04`, `rhel_9`, `rhel_8`, `debian_12`, `windows_2022`, `windows_2019`, `windows_2022_core` |
| `ami_id` | `string` | `null` | Explicit AMI ID; overrides `os_type` |

### CPU Options

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `cpu_core_count` | `number` | `null` | Number of CPU cores; uses instance default when null |
| `cpu_threads_per_core` | `number` | `null` | Threads per core: `1` (disable HT) or `2`; uses instance default when null |
| `cpu_amd_sev_snp` | `string` | `null` | AMD SEV-SNP: `enabled` or `disabled` |

### Placement

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `placement_group_name` | `string` | `null` | Name of an existing placement group |
| `placement_group_partition_number` | `number` | `null` | Partition number (1–7) for partition placement groups |
| `host_id` | `string` | `null` | Dedicated Host ID; only when `tenancy = "host"` |
| `host_resource_group_arn` | `string` | `null` | Host resource group ARN for Dedicated Host auto-placement |

### Key Pair

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_key_pair` | `bool` | `false` | Generate and upload a new key pair |
| `key_pair_name` | `string` | `null` | Name for the new key pair |
| `existing_key_pair_name` | `string` | `null` | Name of an existing key pair |
| `private_key_algorithm` | `string` | `"RSA"` | Key algorithm: `RSA` or `ED25519` |
| `private_key_rsa_bits` | `number` | `4096` | RSA key size: `2048` or `4096` |

### Security Groups

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_security_group` | `bool` | `false` | Create a new security group |
| `security_group_name` | `string` | `null` | Name for the new security group |
| `security_group_description` | `string` | `"Managed by Terraform EC2 module"` | SG description |
| `vpc_id` | `string` | `null` | VPC ID for the new security group |
| `security_group_ingress_rules` | `list(object)` | `[]` | Ingress rules for the new SG |
| `security_group_egress_rules` | `list(object)` | allow-all-egress | Egress rules for the new SG |
| `vpc_security_group_ids` | `list(string)` | `[]` | Existing security group IDs to attach |

### Network Interface

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `primary_network_interface_id` | `string` | `null` | Pre-existing ENI ID to use as eth0; overrides `subnet_id`, `vpc_security_group_ids`, `associate_public_ip_address`, `private_ip` |
| `secondary_network_interfaces` | `list(object)` | `[]` | Additional pre-existing ENIs to attach |

### Networking

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `associate_public_ip_address` | `bool` | `false` | Associate a public IP |
| `private_ip` | `string` | `null` | Static primary private IP address |
| `secondary_private_ips` | `list(string)` | `[]` | Secondary private IPv4 addresses |
| `ipv6_address_count` | `number` | `0` | Number of IPv6 addresses to assign (0–15) |
| `source_dest_check` | `bool` | `true` | Enable source/destination check |
| `private_dns_hostname_type` | `string` | `"ip-name"` | Private DNS hostname type: `ip-name` or `resource-name` |
| `enable_resource_based_naming` | `bool` | `false` | Respond to DNS queries with resource-based name |

### Root EBS Volume

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `root_volume_type` | `string` | `"gp3"` | Root EBS volume type: `gp2`, `gp3`, `io1`, `io2` |
| `root_volume_size` | `number` | `20` | Root EBS volume size in GiB (8–16384) |
| `root_volume_iops` | `number` | `null` | Root EBS IOPS (100–64000; for io1/io2/gp3) |
| `root_volume_throughput` | `number` | `null` | Root EBS throughput in MiB/s (125–1000; gp3 only) |
| `root_volume_encrypted` | `bool` | `true` | Encrypt the root volume |
| `root_volume_kms_key_id` | `string` | `null` | KMS key ID/ARN for root volume encryption |
| `root_volume_delete_on_termination` | `bool` | `true` | Delete root volume on termination |

### Additional EBS Volumes

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `additional_ebs_volumes` | `list(object)` | `[]` | Additional EBS volumes. Each object: `device_name`, `volume_type`, `volume_size`, `iops` (opt), `throughput` (opt), `encrypted` (opt, default `true`), `kms_key_id` (opt), `delete_on_termination` (opt, default `true`), `snapshot_id` (opt) |

### IAM

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `iam_instance_profile` | `string` | `null` | IAM instance profile name to attach |

### Shutdown & Protection

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `instance_initiated_shutdown_behavior` | `string` | `"stop"` | OS shutdown behaviour: `stop` or `terminate` |
| `disable_api_termination` | `bool` | `false` | Enable termination protection |
| `disable_api_stop` | `bool` | `false` | Enable stop protection |
| `hibernation` | `bool` | `false` | Enable hibernation (requires encrypted root volume) |

### Capacity Reservation

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `capacity_reservation_preference` | `string` | `"open"` | Capacity reservation preference: `open` or `none` |
| `capacity_reservation_id` | `string` | `null` | Targeted capacity reservation ID |
| `capacity_reservation_resource_group_arn` | `string` | `null` | Capacity reservation resource group ARN |

### Maintenance & Advanced

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `auto_recovery` | `string` | `"default"` | Auto-recovery behaviour: `default` or `disabled` |
| `nitro_enclave_enabled` | `bool` | `false` | Enable Nitro Enclaves |
| `launch_template_id` | `string` | `null` | Existing launch template ID |
| `launch_template_version` | `string` | `"$Default"` | Launch template version |

### Monitoring & Metadata

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `monitoring` | `bool` | `true` | Enable detailed CloudWatch monitoring |
| `metadata_http_tokens` | `string` | `"required"` | IMDSv2 token requirement: `required` or `optional` |
| `metadata_http_put_response_hop_limit` | `number` | `1` | IMDS hop limit (1–64) |
| `metadata_instance_tags_enabled` | `bool` | `false` | Expose instance tags via IMDS |
| `metadata_ipv6_endpoint` | `string` | `"disabled"` | IPv6 IMDS endpoint: `enabled` or `disabled` |

### User Data & Tags

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `user_data` | `string` | `null` | Base64-encoded user data script |
| `user_data_replace_on_change` | `bool` | `false` | Replace instance on `user_data` change |
| `tags` | `map(string)` | `{}` | Tags to apply to all resources |

---

## 📤 Outputs

### Instance Core

| Name | Description |
|------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_arn` | EC2 instance ARN |
| `instance_state` | Current instance state |
| `instance_type` | Instance type |
| `ami_id` | AMI ID used |
| `availability_zone` | Availability zone |
| `architecture` | Effective CPU architecture (`x86_64` or `arm64`) |

### Networking

| Name | Description |
|------|-------------|
| `subnet_id` | Subnet ID |
| `vpc_id` | VPC ID |
| `private_ip` | Primary private IP address |
| `public_ip` | Public IP address |
| `private_dns` | Private DNS name |
| `public_dns` | Public DNS name |
| `ipv6_addresses` | List of IPv6 addresses |
| `primary_network_interface_id` | Primary network interface ID |
| `vpc_security_group_ids` | Attached security group IDs |

### Key Pair

| Name | Description |
|------|-------------|
| `key_name` | Key pair name |
| `created_key_pair_id` | ID of newly created key pair |
| `private_key_pem` | PEM private key (sensitive) |
| `public_key_openssh` | OpenSSH public key |

### Security Group

| Name | Description |
|------|-------------|
| `created_security_group_id` | ID of newly created security group |
| `created_security_group_arn` | ARN of newly created security group |

### EBS Volumes

| Name | Description |
|------|-------------|
| `root_block_device` | Root EBS block device attributes |
| `ebs_block_devices` | Additional EBS block device attributes |

### Compute / CPU

| Name | Description |
|------|-------------|
| `cpu_core_count` | Number of CPU cores |
| `cpu_threads_per_core` | Threads per CPU core |
| `ebs_optimized` | Whether the instance is EBS-optimised |

### Placement

| Name | Description |
|------|-------------|
| `placement_group` | Placement group name |
| `tenancy` | Instance tenancy |
| `host_id` | Dedicated Host ID |

### IAM & Protection

| Name | Description |
|------|-------------|
| `iam_instance_profile` | IAM instance profile attached |
| `disable_api_termination` | Whether termination protection is enabled |

### Account / Region Context

| Name | Description |
|------|-------------|
| `aws_account_id` | AWS account ID |
| `aws_region` | AWS region |
| `aws_partition` | AWS partition |

---

## 🚀 Quick Start

```hcl
module "ec2" {
  source        = "git::https://github.com/<org>/terraform-aws-ec2-module.git?ref=v1.0.0"
  name          = "myapp-prod-ec2"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0abc1234"
  os_type       = "amazon_linux_2023"

  create_key_pair       = true
  key_pair_name         = "myapp-prod-key"
  create_security_group = true
  security_group_name   = "myapp-prod-sg"
  vpc_id                = "vpc-0abc1234"

  root_volume_type       = "gp3"
  root_volume_size       = 20
  root_volume_iops       = 3000
  root_volume_throughput = 125
  root_volume_encrypted  = true

  tags = { Environment = "prod" }
}
```

### Graviton (arm64) Instance

```hcl
module "ec2_graviton" {
  source                = "git::https://github.com/<org>/terraform-aws-ec2-module.git?ref=v1.0.0"
  name                  = "myapp-prod-graviton"
  instance_type         = "t4g.medium"
  instance_architecture = "arm64"
  subnet_id             = "subnet-0abc1234"
  os_type               = "ubuntu_22_04"

  existing_key_pair_name = "my-existing-key"
  vpc_security_group_ids = ["sg-0abc1234"]

  root_volume_type       = "gp3"
  root_volume_size       = 20
  root_volume_iops       = 3000
  root_volume_throughput = 125
  root_volume_encrypted  = true

  tags = { Environment = "prod" }
}
```

---

## 📁 Module Structure

```
terraform-aws-ec2-module/
├── main.tf               # EC2, key pair, security group resources
├── variables.tf          # All input variables with validation
├── outputs.tf            # Module outputs
├── locals.tf             # AMI config map and computed values
├── data.tf               # Dynamic AMI data sources
├── versions.tf           # Provider version constraints
├── examples/
│   ├── main.tf           # Example usage (x86_64 + Graviton)
│   ├── variables.tf      # Example variables
│   └── README.md         # Example documentation
├── .amazonq/rules/       # Amazon Q best-practice rulesets
├── .github/workflows/    # CI/CD GitHub Actions workflow
├── .gitignore
├── .pre-commit-config.yaml
├── .tflint.hcl
└── trivy.yaml
```

---

## 🔐 Security Considerations

- IMDSv2 is enforced by default (`metadata_http_tokens = "required"`)
- EBS volumes are encrypted by default
- Security group egress defaults to allow-all; restrict for production
- SSH (port 22) and RDP (port 3389) ingress must never use `0.0.0.0/0` as CIDR
- Private keys generated by this module are stored in Terraform state — use a remote backend with encryption and store keys in AWS Secrets Manager or SSM Parameter Store
- Avoid associating public IPs unless required; use a bastion host or SSM Session Manager instead
- Enable termination protection (`disable_api_termination = true`) for production instances
