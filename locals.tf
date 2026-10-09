locals {
  # ── AMI owner and filter mappings per OS × architecture ───────────────────
  ami_config = {
    amazon_linux_2 = {
      owners      = ["amazon"]
      name_filter = var.instance_architecture == "arm64" ? "amzn2-ami-hvm-*-arm64-gp2" : "amzn2-ami-hvm-*-x86_64-gp2"
    }
    amazon_linux_2023 = {
      owners      = ["amazon"]
      name_filter = var.instance_architecture == "arm64" ? "al2023-ami-*-arm64" : "al2023-ami-*-x86_64"
    }
    ubuntu_24_04 = {
      owners      = ["099720109477"] # Canonical
      name_filter = var.instance_architecture == "arm64" ? "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*" : "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    }
    ubuntu_22_04 = {
      owners      = ["099720109477"]
      name_filter = var.instance_architecture == "arm64" ? "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*" : "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
    ubuntu_20_04 = {
      owners      = ["099720109477"]
      name_filter = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    }
    rhel_9 = {
      owners      = ["309956199498"] # Red Hat
      name_filter = var.instance_architecture == "arm64" ? "RHEL-9.*_HVM-*-arm64-*" : "RHEL-9.*_HVM-*-x86_64-*"
    }
    rhel_8 = {
      owners      = ["309956199498"]
      name_filter = "RHEL-8.*_HVM-*-x86_64-*"
    }
    debian_12 = {
      owners      = ["136693071363"] # Debian
      name_filter = "debian-12-amd64-*"
    }
    windows_2022 = {
      owners      = ["801119661308"] # Amazon (Windows)
      name_filter = "Windows_Server-2022-English-Full-Base-*"
    }
    windows_2019 = {
      owners      = ["801119661308"]
      name_filter = "Windows_Server-2019-English-Full-Base-*"
    }
    windows_2022_core = {
      owners      = ["801119661308"]
      name_filter = "Windows_Server-2022-English-Core-Base-*"
    }
  }

  resolved_ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.selected[0].id

  # ── EBS-optimised instance families (all current-gen are EBS-optimised by default) ──
  ebs_optimized_families = ["t3", "t3a", "t4g", "m5", "m5a", "m5n", "m6i", "m6a", "m7i",
    "c5", "c5a", "c5n", "c6i", "c6a", "c7i", "r5", "r5a", "r5n", "r6i",
  "x2idn", "x2iedn", "i3en", "i4i", "g4dn", "g5", "p3", "p4d", "inf1", "inf2"]

  instance_family  = split(".", var.instance_type)[0]
  is_ebs_optimized = contains(local.ebs_optimized_families, local.instance_family)

  graviton_families = ["t4g", "m6g", "m6gd", "m7g", "c6g", "c6gd", "c6gn", "c7g",
  "r6g", "r6gd", "r7g", "x2gd", "im4gn", "is4gen"]

  is_graviton = contains(local.graviton_families, local.instance_family)

  # ── Effective architecture: explicit var wins, else infer from family ────────
  effective_architecture = var.instance_architecture != null ? var.instance_architecture : (local.is_graviton ? "arm64" : "x86_64")

  # ── Placement group: only attach when a name is provided ────────────────────
  use_placement_group = var.placement_group_name != null

  # ── Network: use ENI attachment when primary_network_interface_id is set ────
  use_network_interface = var.primary_network_interface_id != null

  common_tags = merge(
    var.tags,
    {
      ManagedBy    = "Terraform"
      Module       = "terraform-aws-ec2-module"
      Architecture = local.effective_architecture
    }
  )
}
