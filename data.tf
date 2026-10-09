data "aws_ami" "selected" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = local.ami_config[var.os_type].owners

  filter {
    name   = "name"
    values = [local.ami_config[var.os_type].name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [local.effective_architecture]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Used for ARN construction and partition-aware defaults
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
