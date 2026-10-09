# ─── Instance Core ────────────────────────────────────────────────────────────

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "instance_state" {
  description = "Current state of the EC2 instance."
  value       = aws_instance.this.instance_state
}

output "instance_type" {
  description = "Instance type of the EC2 instance."
  value       = aws_instance.this.instance_type
}

output "ami_id" {
  description = "AMI ID used to launch the instance."
  value       = aws_instance.this.ami
}

output "availability_zone" {
  description = "Availability zone where the instance is running."
  value       = aws_instance.this.availability_zone
}

output "architecture" {
  description = "Effective CPU architecture used for AMI selection (x86_64 or arm64)."
  value       = local.effective_architecture
}

# ─── Networking ───────────────────────────────────────────────────────────────

output "subnet_id" {
  description = "Subnet ID where the instance is running."
  value       = aws_instance.this.subnet_id
}

output "vpc_id" {
  description = "VPC ID of the subnet where the instance is running."
  value       = aws_instance.this.vpc_id
}

output "private_ip" {
  description = "Primary private IP address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance (null if not associated)."
  value       = aws_instance.this.public_ip
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.this.private_dns
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.this.public_dns
}

output "ipv6_addresses" {
  description = "List of IPv6 addresses assigned to the primary network interface."
  value       = aws_instance.this.ipv6_addresses
}

output "primary_network_interface_id" {
  description = "ID of the primary network interface (eth0)."
  value       = aws_instance.this.primary_network_interface_id
}

output "vpc_security_group_ids" {
  description = "Security group IDs attached to the instance."
  value       = aws_instance.this.vpc_security_group_ids
}

# ─── Key Pair ─────────────────────────────────────────────────────────────────

output "key_name" {
  description = "Key pair name associated with the instance."
  value       = aws_instance.this.key_name
}

output "created_key_pair_id" {
  description = "ID of the newly created key pair (null if using an existing key pair)."
  value       = var.create_key_pair ? aws_key_pair.created[0].id : null
}

output "private_key_pem" {
  description = "PEM-encoded private key. Only populated when create_key_pair is true. Store in Secrets Manager or SSM Parameter Store."
  value       = var.create_key_pair ? tls_private_key.generated[0].private_key_pem : null
  sensitive   = true
}

output "public_key_openssh" {
  description = "OpenSSH-formatted public key. Only populated when create_key_pair is true."
  value       = var.create_key_pair ? tls_private_key.generated[0].public_key_openssh : null
}

# ─── Security Group ───────────────────────────────────────────────────────────

output "created_security_group_id" {
  description = "ID of the newly created security group (null if not created by this module)."
  value       = var.create_security_group ? aws_security_group.created[0].id : null
}

output "created_security_group_arn" {
  description = "ARN of the newly created security group (null if not created by this module)."
  value       = var.create_security_group ? aws_security_group.created[0].arn : null
}

# ─── EBS Volumes ──────────────────────────────────────────────────────────────

output "root_block_device" {
  description = "Root EBS block device attributes."
  value       = aws_instance.this.root_block_device
}

output "ebs_block_devices" {
  description = "Additional EBS block device attributes."
  value       = aws_instance.this.ebs_block_device
}

# ─── Compute / CPU ────────────────────────────────────────────────────────────

output "cpu_core_count" {
  description = "Number of CPU cores on the instance."
  value       = aws_instance.this.cpu_core_count
}

output "cpu_threads_per_core" {
  description = "Number of threads per CPU core."
  value       = aws_instance.this.cpu_threads_per_core
}

output "ebs_optimized" {
  description = "Whether the instance is EBS-optimised."
  value       = aws_instance.this.ebs_optimized
}

# ─── Placement ────────────────────────────────────────────────────────────────

output "placement_group" {
  description = "Placement group the instance belongs to (empty string if none)."
  value       = aws_instance.this.placement_group
}

output "tenancy" {
  description = "Tenancy of the instance."
  value       = aws_instance.this.tenancy
}

output "host_id" {
  description = "ID of the Dedicated Host the instance is running on (null if not applicable)."
  value       = aws_instance.this.host_id
}

# ─── IAM ──────────────────────────────────────────────────────────────────────

output "iam_instance_profile" {
  description = "IAM instance profile attached to the instance."
  value       = aws_instance.this.iam_instance_profile
}

# ─── Protection ───────────────────────────────────────────────────────────────

output "disable_api_termination" {
  description = "Whether termination protection is enabled."
  value       = aws_instance.this.disable_api_termination
}

# ─── Account / Region Context ─────────────────────────────────────────────────

output "aws_account_id" {
  description = "AWS account ID in which the instance was created."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region in which the instance was created."
  value       = data.aws_region.current.name
}

output "aws_partition" {
  description = "AWS partition (aws, aws-cn, aws-us-gov) in which the instance was created."
  value       = data.aws_partition.current.partition
}
