variable "aws_region" {
  description = "AWS region to deploy the example EC2 instances."
  type        = string
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "Subnet ID in which to launch the example instances."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the example security group."
  type        = string
}

variable "existing_key_pair_name" {
  description = "Name of an existing EC2 key pair to use for the Graviton example."
  type        = string
  default     = null
}

variable "existing_security_group_ids" {
  description = "List of existing security group IDs to attach to the Graviton example instance."
  type        = list(string)
  default     = []
}
