# Amazon Q Rules – EC2 Module Security & Best Practices
# These rules are automatically applied to every Amazon Q chat and inline suggestion
# within this workspace.

## Terraform General Rules

- Always pin provider versions using `>=` with a minimum version, never use `~>` without a floor.
- Every resource must have a `Name` tag and inherit from a `tags` variable merged with module-level common tags.
- Never hardcode AWS account IDs, region names, AMI IDs, or IP addresses in resource definitions; use variables or data sources.
- All `count` and `for_each` meta-arguments must be deterministic at plan time.
- Use `lifecycle { ignore_changes = [ami] }` on EC2 instances to prevent drift from AMI updates.

## EC2 Security Rules

- IMDSv2 (`http_tokens = "required"`) must always be enforced on every EC2 instance.
- The `metadata_http_put_response_hop_limit` must be set to `1` unless a container workload explicitly requires a higher value.
- EBS volumes (root and additional) must always have `encrypted = true`.
- Never set `associate_public_ip_address = true` without an explicit justification comment in the code.
- Security groups must never use `0.0.0.0/0` as an ingress CIDR for SSH (port 22) or RDP (port 3389).
- Prefer `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` over inline `ingress`/`egress` blocks in `aws_security_group`.

## Key Pair Rules

- Never commit private key material to source control.
- When `create_key_pair = true`, the `private_key_pem` output must be marked `sensitive = true`.
- Prefer RSA 4096-bit or ED25519 keys over RSA 2048-bit.
- Store generated private keys in AWS Secrets Manager or SSM Parameter Store (SecureString), not in Terraform state alone.

## EBS Volume Rules

- Always prefer `gp3` over `gp2` for new volumes (better price/performance).
- Set `delete_on_termination = false` for data volumes that must survive instance termination.
- Specify explicit IOPS and throughput for `gp3` volumes rather than relying on defaults.
- Use a customer-managed KMS key (`kms_key_id`) for volumes storing sensitive data.

## IAM Rules

- Attach IAM instance profiles via the `iam_instance_profile` variable; never embed IAM policies inline in EC2 resources.
- Follow least-privilege: instance profiles should only have permissions required for the workload.

## Monitoring & Observability Rules

- Always enable detailed CloudWatch monitoring (`monitoring = true`) for production instances.
- Ensure CloudWatch agent or SSM agent is installed via `user_data` for instances that require log shipping.

## Terraform Code Quality Rules

- All variables must have a `description` and a `validation` block where the value space is finite or bounded.
- All outputs must have a `description`.
- Run `terraform fmt` before every commit; CI must fail on formatting drift.
- Run `terraform validate` and `tflint` in CI before merging any PR.
- Module `source` references in examples must use a relative path (`../`) for local testing and a versioned Git URL for production.

## Naming Convention Rules

- Resource names must follow the pattern: `<project>-<environment>-<resource-type>` (e.g. `myapp-prod-ec2`).
- Variable names must use `snake_case`.
- Local values must use `snake_case`.
- Output names must use `snake_case`.
