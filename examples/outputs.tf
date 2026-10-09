output "standard_instance_id" {
  description = "Instance ID of the standard x86_64 example."
  value       = module.ec2_standard.instance_id
}

output "standard_private_ip" {
  description = "Primary private IP of the standard x86_64 example."
  value       = module.ec2_standard.private_ip
}

output "standard_architecture" {
  description = "CPU architecture of the standard x86_64 example."
  value       = module.ec2_standard.architecture
}

output "graviton_instance_id" {
  description = "Instance ID of the Graviton arm64 example."
  value       = module.ec2_graviton.instance_id
}

output "graviton_architecture" {
  description = "CPU architecture of the Graviton arm64 example."
  value       = module.ec2_graviton.architecture
}
