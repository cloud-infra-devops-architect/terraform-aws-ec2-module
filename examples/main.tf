provider "aws" {
  region = var.aws_region
}

# ── Example 1: Standard x86_64 instance (Amazon Linux 2023) ──────────────────
module "ec2_standard" {
  source = "../"

  name          = "example-web-server"
  instance_type = "t3.medium"
  tenancy       = "default"
  subnet_id     = var.subnet_id
  os_type       = "amazon_linux_2023"

  # Key pair – generate a new RSA 4096-bit key
  create_key_pair       = true
  key_pair_name         = "example-web-server-key"
  private_key_algorithm = "RSA"
  private_key_rsa_bits  = 4096

  # Security group
  create_security_group      = true
  security_group_name        = "example-web-server-sg"
  security_group_description = "Allow SSH from RFC-1918 and HTTP/HTTPS from anywhere"
  vpc_id                     = var.vpc_id

  security_group_ingress_rules = [
    {
      description = "SSH from internal networks only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # CPU options – disable hyperthreading for security-sensitive workloads
  cpu_core_count       = 1
  cpu_threads_per_core = 1

  # Root EBS volume
  root_volume_type       = "gp3"
  root_volume_size       = 30
  root_volume_iops       = 3000
  root_volume_throughput = 125
  root_volume_encrypted  = true

  # Additional data volume that survives instance termination
  additional_ebs_volumes = [
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp3"
      volume_size           = 100
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      delete_on_termination = false
    }
  ]

  # Networking
  associate_public_ip_address = false
  secondary_private_ips       = ["10.0.1.10"]
  private_dns_hostname_type   = "ip-name"

  # Shutdown / protection
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination              = true
  disable_api_stop                     = false

  # Capacity reservation – open preference
  capacity_reservation_preference = "open"

  # Maintenance / auto-recovery
  auto_recovery = "default"

  # Monitoring & metadata
  monitoring                           = true
  metadata_http_tokens                 = "required"
  metadata_http_put_response_hop_limit = 1
  metadata_instance_tags_enabled       = true

  tags = {
    Environment = "dev"
    Project     = "example"
    CostCenter  = "engineering"
  }
}

# ── Example 2: Graviton (arm64) instance (Ubuntu 22.04) ──────────────────────
module "ec2_graviton" {
  source = "../"

  name                  = "example-graviton-server"
  instance_type         = "t4g.medium"
  instance_architecture = "arm64"
  subnet_id             = var.subnet_id
  os_type               = "ubuntu_22_04"

  existing_key_pair_name = var.existing_key_pair_name

  vpc_security_group_ids = var.existing_security_group_ids

  root_volume_type       = "gp3"
  root_volume_size       = 20
  root_volume_iops       = 3000
  root_volume_throughput = 125
  root_volume_encrypted  = true

  monitoring              = true
  metadata_http_tokens    = "required"
  disable_api_termination = false

  tags = {
    Environment = "dev"
    Project     = "example-graviton"
  }
}

