# ─── Key Pair ─────────────────────────────────────────────────────────────────

resource "tls_private_key" "generated" {
  count     = var.create_key_pair && var.existing_key_pair_name == null ? 1 : 0
  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_algorithm == "RSA" ? var.private_key_rsa_bits : null
}

resource "aws_key_pair" "created" {
  count      = var.create_key_pair && var.existing_key_pair_name == null ? 1 : 0
  key_name   = var.key_pair_name
  public_key = tls_private_key.generated[0].public_key_openssh

  tags = local.common_tags
}

# ─── Security Group ───────────────────────────────────────────────────────────

resource "aws_security_group" "created" {
  #checkov:skip=CKV2_AWS_5: Security group is attached to aws_instance.this via vpc_security_group_ids; static analysis cannot trace cross-resource references within a module.
  count       = var.create_security_group ? 1 : 0
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, { Name = var.security_group_name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "created" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_ingress_rules : tostring(idx) => rule
  } : {}

  security_group_id = aws_security_group.created[0].id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks[0]

  tags = local.common_tags
}

# trivy:ignore:AVD-AWS-0104 -- Egress CIDR is caller-supplied via security_group_egress_rules; default allow-all is intentional and documented. Restrict in production via the variable.
resource "aws_vpc_security_group_egress_rule" "created" {
  for_each = var.create_security_group ? {
    for idx, rule in var.security_group_egress_rules : tostring(idx) => rule
  } : {}

  security_group_id = aws_security_group.created[0].id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks[0]

  tags = local.common_tags
}

# ─── EC2 Instance ─────────────────────────────────────────────────────────────

resource "aws_instance" "this" {
  ami           = local.resolved_ami_id
  instance_type = var.instance_type
  tenancy       = var.tenancy

  # Placement
  availability_zone       = var.availability_zone
  placement_group         = local.use_placement_group ? var.placement_group_name : null
  host_id                 = var.host_id
  host_resource_group_arn = var.host_resource_group_arn

  # Networking – mutually exclusive paths: ENI attachment vs. subnet-level config
  subnet_id                   = local.use_network_interface ? null : var.subnet_id
  associate_public_ip_address = local.use_network_interface ? null : var.associate_public_ip_address
  private_ip                  = local.use_network_interface ? null : var.private_ip
  secondary_private_ips       = local.use_network_interface ? [] : var.secondary_private_ips
  ipv6_address_count          = local.use_network_interface ? null : var.ipv6_address_count
  source_dest_check           = local.use_network_interface ? null : var.source_dest_check

  vpc_security_group_ids = local.use_network_interface ? [] : concat(
    var.vpc_security_group_ids,
    var.create_security_group ? [aws_security_group.created[0].id] : []
  )

  # Primary ENI attachment (when pre-existing ENI is provided)
  dynamic "network_interface" {
    for_each = local.use_network_interface ? [1] : []
    content {
      network_interface_id = var.primary_network_interface_id
      device_index         = 0
    }
  }

  # Secondary ENI attachments
  dynamic "network_interface" {
    for_each = { for eni in var.secondary_network_interfaces : tostring(eni.device_index) => eni }
    content {
      network_interface_id = network_interface.value.network_interface_id
      device_index         = network_interface.value.device_index
    }
  }

  # IAM / Key
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.create_key_pair ? aws_key_pair.created[0].key_name : var.existing_key_pair_name

  # Compute
  ebs_optimized = local.is_ebs_optimized
  monitoring    = var.monitoring
  hibernation   = var.hibernation

  # Shutdown / termination protection
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  disable_api_termination              = var.disable_api_termination
  disable_api_stop                     = var.disable_api_stop

  # User data
  user_data_base64            = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  # ── CPU Options ─────────────────────────────────────────────────────────────
  dynamic "cpu_options" {
    for_each = var.cpu_core_count != null || var.cpu_threads_per_core != null || var.cpu_amd_sev_snp != null ? [1] : []
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
      amd_sev_snp      = var.cpu_amd_sev_snp
    }
  }

  placement_partition_number = var.placement_group_partition_number


  # ── Root EBS Volume ──────────────────────────────────────────────────────────
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = contains(["io1", "io2", "gp3"], var.root_volume_type) ? var.root_volume_iops : null
    throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id
    delete_on_termination = var.root_volume_delete_on_termination

    tags = merge(local.common_tags, { Name = "${var.name}-root" })
  }

  # ── Additional EBS Volumes ───────────────────────────────────────────────────
  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = ebs_block_device.value.volume_type
      volume_size           = ebs_block_device.value.volume_size
      snapshot_id           = ebs_block_device.value.snapshot_id
      iops                  = contains(["io1", "io2", "gp3"], ebs_block_device.value.volume_type) ? ebs_block_device.value.iops : null
      throughput            = ebs_block_device.value.volume_type == "gp3" ? ebs_block_device.value.throughput : null
      encrypted             = ebs_block_device.value.encrypted
      kms_key_id            = ebs_block_device.value.kms_key_id
      delete_on_termination = ebs_block_device.value.delete_on_termination

      tags = merge(local.common_tags, { Name = "${var.name}-${ebs_block_device.value.device_name}" })
    }
  }

  # ── IMDSv2 / Metadata ────────────────────────────────────────────────────────
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_instance_tags_enabled ? "enabled" : "disabled"
    http_protocol_ipv6          = var.metadata_ipv6_endpoint
  }

  # ── Private DNS Name Options ─────────────────────────────────────────────────
  private_dns_name_options {
    hostname_type                        = var.private_dns_hostname_type
    enable_resource_name_dns_a_record    = var.private_dns_hostname_type == "resource-name" ? var.enable_resource_based_naming : false
    enable_resource_name_dns_aaaa_record = var.private_dns_hostname_type == "resource-name" && var.ipv6_address_count > 0 ? var.enable_resource_based_naming : false
  }

  # ── Capacity Reservation ─────────────────────────────────────────────────────
  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_id != null || var.capacity_reservation_resource_group_arn != null ? [1] : [0]
    content {
      capacity_reservation_preference = var.capacity_reservation_id != null || var.capacity_reservation_resource_group_arn != null ? null : var.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = var.capacity_reservation_id != null || var.capacity_reservation_resource_group_arn != null ? [1] : []
        content {
          capacity_reservation_id                 = var.capacity_reservation_id
          capacity_reservation_resource_group_arn = var.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  # ── Maintenance Options (auto-recovery) ──────────────────────────────────────
  maintenance_options {
    auto_recovery = var.auto_recovery
  }

  # ── Nitro Enclave ────────────────────────────────────────────────────────────
  dynamic "enclave_options" {
    for_each = var.nitro_enclave_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # ── Launch Template ──────────────────────────────────────────────────────────
  dynamic "launch_template" {
    for_each = var.launch_template_id != null ? [1] : []
    content {
      id      = var.launch_template_id
      version = var.launch_template_version
    }
  }

  tags = merge(local.common_tags, { Name = var.name })

  lifecycle {
    ignore_changes = [ami]
  }
}
