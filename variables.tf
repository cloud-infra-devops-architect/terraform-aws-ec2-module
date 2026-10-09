# ─── Instance ─────────────────────────────────────────────────────────────────

variable "name" {
  description = "Name tag applied to the EC2 instance and all related resources."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "name must be between 1 and 255 characters."
  }
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.micro, m6i.large, c7g.medium)."
  type        = string

  validation {
    condition = can(regex(
      "^(t2|t3|t3a|t4g|m5|m5a|m5n|m5zn|m6i|m6a|m6in|m7i|c5|c5a|c5n|c6i|c6a|c6in|c7i|r5|r5a|r5b|r5n|r6i|r6a|x2idn|x2iedn|i3en|i4i|g4dn|g5|p3|p4d|inf1|inf2)\\.(nano|micro|small|medium|large|xlarge|2xlarge|4xlarge|8xlarge|12xlarge|16xlarge|24xlarge|32xlarge|48xlarge|metal)$",
      var.instance_type
    ))
    error_message = "instance_type must be a valid current-generation EC2 instance type (e.g. t3.micro, m6i.large)."
  }
}

variable "instance_architecture" {
  description = "CPU architecture for AMI selection. Valid values: x86_64, arm64. When null the module infers from the instance family (Graviton families → arm64, all others → x86_64)."
  type        = string
  default     = null

  validation {
    condition     = var.instance_architecture == null || contains(["x86_64", "arm64"], var.instance_architecture)
    error_message = "instance_architecture must be x86_64, arm64, or null."
  }
}

variable "tenancy" {
  description = "Instance tenancy. Valid values: default, dedicated, host."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.tenancy)
    error_message = "tenancy must be one of: default, dedicated, host."
  }
}

variable "subnet_id" {
  description = "ID of the subnet in which to launch the instance. Not used when primary_network_interface_id is set."
  type        = string
  default     = null

  validation {
    condition     = var.subnet_id == null || can(regex("^subnet-[a-z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid AWS subnet ID (e.g. subnet-0abc1234) or null."
  }
}

variable "availability_zone" {
  description = "Availability zone in which to launch the instance. When null, AWS selects automatically."
  type        = string
  default     = null
}

# ─── AMI / OS ─────────────────────────────────────────────────────────────────

variable "os_type" {
  description = "Operating system for automatic latest-AMI selection. Ignored when ami_id is set. Supported values: amazon_linux_2, amazon_linux_2023, ubuntu_24_04, ubuntu_22_04, ubuntu_20_04, rhel_9, rhel_8, debian_12, windows_2022, windows_2019, windows_2022_core."
  type        = string
  default     = "amazon_linux_2023"

  validation {
    condition = contains([
      "amazon_linux_2", "amazon_linux_2023",
      "ubuntu_24_04", "ubuntu_22_04", "ubuntu_20_04",
      "rhel_9", "rhel_8",
      "debian_12",
      "windows_2022", "windows_2019", "windows_2022_core"
    ], var.os_type)
    error_message = "os_type must be one of: amazon_linux_2, amazon_linux_2023, ubuntu_24_04, ubuntu_22_04, ubuntu_20_04, rhel_9, rhel_8, debian_12, windows_2022, windows_2019, windows_2022_core."
  }
}

variable "ami_id" {
  description = "Explicit AMI ID. When set, os_type and instance_architecture-based AMI lookup are skipped."
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[a-z0-9]+$", var.ami_id))
    error_message = "ami_id must be a valid AMI ID (e.g. ami-0abc1234) or null."
  }
}

# ─── CPU Options ──────────────────────────────────────────────────────────────

variable "cpu_core_count" {
  description = "Number of CPU cores for the instance. When null, the default for the instance type is used. Must be used together with cpu_threads_per_core."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_core_count == null || var.cpu_core_count >= 1
    error_message = "cpu_core_count must be a positive integer or null."
  }
}

variable "cpu_threads_per_core" {
  description = "Number of threads per CPU core. Set to 1 to disable hyperthreading. Valid values: 1 or 2."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_threads_per_core == null || contains([1, 2], var.cpu_threads_per_core)
    error_message = "cpu_threads_per_core must be 1 (disable HT) or 2 (enable HT), or null."
  }
}

variable "cpu_amd_sev_snp" {
  description = "AMD SEV-SNP (Secure Encrypted Virtualisation – Secure Nested Paging) for supported instance types. Valid values: enabled, disabled."
  type        = string
  default     = null

  validation {
    condition     = var.cpu_amd_sev_snp == null || contains(["enabled", "disabled"], var.cpu_amd_sev_snp)
    error_message = "cpu_amd_sev_snp must be 'enabled', 'disabled', or null."
  }
}

# ─── Placement ────────────────────────────────────────────────────────────────

variable "placement_group_name" {
  description = "Name of an existing placement group to launch the instance into. When null, no placement group is used."
  type        = string
  default     = null
}

variable "placement_group_partition_number" {
  description = "Partition number for partition placement groups (1–7). Only relevant when the placement group strategy is 'partition'."
  type        = number
  default     = null

  validation {
    condition     = var.placement_group_partition_number == null || (var.placement_group_partition_number >= 1 && var.placement_group_partition_number <= 7)
    error_message = "placement_group_partition_number must be between 1 and 7, or null."
  }
}

variable "host_id" {
  description = "ID of a Dedicated Host on which to launch the instance. Only applicable when tenancy is 'host'."
  type        = string
  default     = null
}

variable "host_resource_group_arn" {
  description = "ARN of the host resource group for Dedicated Host auto-placement. Only applicable when tenancy is 'host'."
  type        = string
  default     = null
}

# ─── Key Pair ─────────────────────────────────────────────────────────────────

variable "create_key_pair" {
  description = "When true, a new key pair is generated and uploaded to AWS. Mutually exclusive with existing_key_pair_name."
  type        = bool
  default     = false
}

variable "existing_key_pair_name" {
  description = "Name of an existing EC2 key pair to associate with the instance. Ignored when create_key_pair is true."
  type        = string
  default     = null
}

variable "key_pair_name" {
  description = "Name for the newly created key pair. Required when create_key_pair is true."
  type        = string
  default     = null
}

variable "private_key_algorithm" {
  description = "Algorithm for the generated private key. Valid values: RSA, ED25519."
  type        = string
  default     = "RSA"

  validation {
    condition     = contains(["RSA", "ED25519"], var.private_key_algorithm)
    error_message = "private_key_algorithm must be RSA or ED25519."
  }
}

variable "private_key_rsa_bits" {
  description = "Bit-length for RSA key generation. Applicable only when private_key_algorithm is RSA."
  type        = number
  default     = 4096

  validation {
    condition     = contains([2048, 4096], var.private_key_rsa_bits)
    error_message = "private_key_rsa_bits must be 2048 or 4096."
  }
}

# ─── Security Groups ──────────────────────────────────────────────────────────

variable "vpc_security_group_ids" {
  description = "List of existing security group IDs to attach to the instance. Not used when primary_network_interface_id is set."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for sg in var.vpc_security_group_ids : can(regex("^sg-[a-z0-9]+$", sg))])
    error_message = "Each security group ID must match the pattern sg-xxxxxxxx."
  }
}

variable "create_security_group" {
  description = "When true, a new security group is created and attached to the instance."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name for the newly created security group. Required when create_security_group is true."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for the newly created security group."
  type        = string
  default     = "Managed by Terraform EC2 module"
}

variable "vpc_id" {
  description = "VPC ID for the new security group. Required when create_security_group is true."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID (e.g. vpc-0abc1234) or null."
  }
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the new security group."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = "List of egress rules for the new security group."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# ─── Network Interface ────────────────────────────────────────────────────────

variable "primary_network_interface_id" {
  description = "ID of a pre-existing ENI to attach as the primary network interface (eth0). When set, subnet_id, vpc_security_group_ids, associate_public_ip_address, and private_ip are ignored."
  type        = string
  default     = null

  validation {
    condition     = var.primary_network_interface_id == null || can(regex("^eni-[a-z0-9]+$", var.primary_network_interface_id))
    error_message = "primary_network_interface_id must be a valid ENI ID (e.g. eni-0abc1234) or null."
  }
}

variable "secondary_network_interfaces" {
  description = "List of additional pre-existing ENIs to attach to the instance."
  type = list(object({
    network_interface_id = string
    device_index         = number
  }))
  default = []

  validation {
    condition     = alltrue([for eni in var.secondary_network_interfaces : can(regex("^eni-[a-z0-9]+$", eni.network_interface_id))])
    error_message = "Each network_interface_id must be a valid ENI ID (e.g. eni-0abc1234)."
  }

  validation {
    condition     = alltrue([for eni in var.secondary_network_interfaces : eni.device_index >= 1 && eni.device_index <= 31])
    error_message = "device_index for secondary interfaces must be between 1 and 31."
  }
}

# ─── EBS Root Volume ──────────────────────────────────────────────────────────

variable "root_volume_type" {
  description = "EBS volume type for the root volume. Valid values: gp2, gp3, io1, io2."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "root_volume_type must be one of: gp2, gp3, io1, io2."
  }
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB (8–16384)."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "root_volume_size must be between 8 and 16384 GiB."
  }
}

variable "root_volume_iops" {
  description = "Provisioned IOPS for the root EBS volume. Applicable for io1, io2, and gp3 types."
  type        = number
  default     = null

  validation {
    condition     = var.root_volume_iops == null || (var.root_volume_iops >= 100 && var.root_volume_iops <= 64000)
    error_message = "root_volume_iops must be between 100 and 64000, or null."
  }
}

variable "root_volume_throughput" {
  description = "Throughput in MiB/s for the root EBS volume. Applicable for gp3 only (125–1000)."
  type        = number
  default     = null

  validation {
    condition     = var.root_volume_throughput == null || (var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000)
    error_message = "root_volume_throughput must be between 125 and 1000 MiB/s, or null."
  }
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root EBS volume."
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID or ARN for root volume encryption. Uses the AWS-managed key when null."
  type        = string
  default     = null
}

variable "root_volume_delete_on_termination" {
  description = "Whether the root EBS volume is deleted when the instance is terminated."
  type        = bool
  default     = true
}

# ─── Additional EBS Volumes ───────────────────────────────────────────────────

variable "additional_ebs_volumes" {
  description = "List of additional EBS volumes to attach to the instance."
  type = list(object({
    device_name           = string
    volume_type           = string
    volume_size           = number
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
    snapshot_id           = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for v in var.additional_ebs_volumes : contains(["gp2", "gp3", "io1", "io2", "sc1", "st1"], v.volume_type)])
    error_message = "Each additional volume type must be one of: gp2, gp3, io1, io2, sc1, st1."
  }

  validation {
    condition     = alltrue([for v in var.additional_ebs_volumes : v.volume_size >= 1 && v.volume_size <= 16384])
    error_message = "Each additional volume size must be between 1 and 16384 GiB."
  }
}

# ─── Networking ───────────────────────────────────────────────────────────────

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address. Not used when primary_network_interface_id is set. # tfsec:ignore:aws-ec2-no-public-ip"
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Static private IP address to assign. Auto-assigned when null."
  type        = string
  default     = null

  validation {
    condition     = var.private_ip == null || can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.private_ip))
    error_message = "private_ip must be a valid IPv4 address or null."
  }
}

variable "secondary_private_ips" {
  description = "List of secondary private IPv4 addresses to assign to the primary network interface."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for ip in var.secondary_private_ips : can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", ip))])
    error_message = "Each secondary_private_ip must be a valid IPv4 address."
  }
}

variable "ipv6_address_count" {
  description = "Number of IPv6 addresses to assign to the primary network interface. Requires a dual-stack subnet."
  type        = number
  default     = 0

  validation {
    condition     = var.ipv6_address_count >= 0 && var.ipv6_address_count <= 15
    error_message = "ipv6_address_count must be between 0 and 15."
  }
}

variable "source_dest_check" {
  description = "Enable source/destination check. Set to false for NAT or routing instances."
  type        = bool
  default     = true
}

variable "private_dns_hostname_type" {
  description = "Type of private DNS hostname for the instance. Valid values: ip-name, resource-name."
  type        = string
  default     = "ip-name"

  validation {
    condition     = contains(["ip-name", "resource-name"], var.private_dns_hostname_type)
    error_message = "private_dns_hostname_type must be 'ip-name' or 'resource-name'."
  }
}

variable "enable_resource_based_naming" {
  description = "Whether to respond to DNS queries with the resource-based name. Requires private_dns_hostname_type = 'resource-name'."
  type        = bool
  default     = false
}

# ─── IAM ──────────────────────────────────────────────────────────────────────

variable "iam_instance_profile" {
  description = "Name of an existing IAM instance profile to attach to the instance."
  type        = string
  default     = null
}

# ─── Shutdown & Termination Behaviour ────────────────────────────────────────

variable "instance_initiated_shutdown_behavior" {
  description = "Behaviour when the OS shuts down the instance. Valid values: stop, terminate."
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "instance_initiated_shutdown_behavior must be 'stop' or 'terminate'."
  }
}

variable "disable_api_termination" {
  description = "Enable EC2 termination protection. When true, the instance cannot be terminated via the API or console without first disabling this flag."
  type        = bool
  default     = false
}

variable "disable_api_stop" {
  description = "Enable EC2 stop protection. When true, the instance cannot be stopped via the API or console."
  type        = bool
  default     = false
}

# ─── Hibernation ──────────────────────────────────────────────────────────────

variable "hibernation" {
  description = "Enable hibernation for the instance. Requires an encrypted root volume and a supported instance type."
  type        = bool
  default     = false
}

# ─── Capacity Reservation ─────────────────────────────────────────────────────

variable "capacity_reservation_preference" {
  description = "Capacity reservation preference. Valid values: open, none."
  type        = string
  default     = "open"

  validation {
    condition     = contains(["open", "none"], var.capacity_reservation_preference)
    error_message = "capacity_reservation_preference must be 'open' or 'none'."
  }
}

variable "capacity_reservation_id" {
  description = "ID of a targeted capacity reservation. When set, capacity_reservation_preference is ignored."
  type        = string
  default     = null
}

variable "capacity_reservation_resource_group_arn" {
  description = "ARN of a capacity reservation resource group. When set, capacity_reservation_preference is ignored."
  type        = string
  default     = null
}

# ─── Maintenance Options ──────────────────────────────────────────────────────

variable "auto_recovery" {
  description = "Automatic recovery behaviour for the instance. Valid values: default, disabled."
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "disabled"], var.auto_recovery)
    error_message = "auto_recovery must be 'default' or 'disabled'."
  }
}

# ─── Nitro Enclave ────────────────────────────────────────────────────────────

variable "nitro_enclave_enabled" {
  description = "Enable Nitro Enclaves on the instance. Requires a Nitro-based instance type and cpu_threads_per_core = 1."
  type        = bool
  default     = false
}

# ─── Launch Template ──────────────────────────────────────────────────────────

variable "launch_template_id" {
  description = "ID of an existing launch template to use. When set, launch_template_version must also be provided."
  type        = string
  default     = null

  validation {
    condition     = var.launch_template_id == null || can(regex("^lt-[a-z0-9]+$", var.launch_template_id))
    error_message = "launch_template_id must be a valid launch template ID (e.g. lt-0abc1234) or null."
  }
}

variable "launch_template_version" {
  description = "Version of the launch template to use. Use '$Latest' or '$Default' for dynamic resolution."
  type        = string
  default     = "$Default"
}

# ─── Monitoring & Metadata ────────────────────────────────────────────────────

variable "monitoring" {
  description = "Enable detailed CloudWatch monitoring (1-minute metrics)."
  type        = bool
  default     = true
}

variable "metadata_http_tokens" {
  description = "IMDSv2 token enforcement. Use 'required' to enforce IMDSv2 (recommended)."
  type        = string
  default     = "required"

  validation {
    condition     = contains(["optional", "required"], var.metadata_http_tokens)
    error_message = "metadata_http_tokens must be 'optional' or 'required'."
  }
}

variable "metadata_http_put_response_hop_limit" {
  description = "Maximum number of network hops for the IMDSv2 PUT response (1–64). Use 1 for standard workloads; increase only for containers."
  type        = number
  default     = 1

  validation {
    condition     = var.metadata_http_put_response_hop_limit >= 1 && var.metadata_http_put_response_hop_limit <= 64
    error_message = "metadata_http_put_response_hop_limit must be between 1 and 64."
  }
}

variable "metadata_instance_tags_enabled" {
  description = "Allow instance tags to be accessed from the instance metadata service."
  type        = bool
  default     = false
}

variable "metadata_ipv6_endpoint" {
  description = "Enable the IPv6 endpoint for the instance metadata service. Valid values: enabled, disabled."
  type        = string
  default     = "disabled"

  validation {
    condition     = contains(["enabled", "disabled"], var.metadata_ipv6_endpoint)
    error_message = "metadata_ipv6_endpoint must be 'enabled' or 'disabled'."
  }
}

# ─── User Data ────────────────────────────────────────────────────────────────

variable "user_data" {
  description = "Base64-encoded user data script executed on first launch."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_data_replace_on_change" {
  description = "When true, any change to user_data forces instance replacement."
  type        = bool
  default     = false
}

# ─── Tags ─────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Map of additional tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
