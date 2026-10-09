# Amazon Q Rules – CI/CD & Workflow Standards

## GitHub Actions Workflow Rules

- Every workflow that modifies infrastructure must require manual approval for `production` environments.
- Secrets must never be echoed in workflow logs; use `::add-mask::` or GitHub encrypted secrets.
- Pin all third-party GitHub Actions to a full commit SHA, not a mutable tag.
- Workflows must run security scans (Checkov, Trivy, TFLint, Gitleaks) before any Terraform operation.
- PR merge to `main`, `dev`, or `qa` branches must be blocked unless all scan and validation jobs pass.

## Pre-commit Rules

- The `.pre-commit-config.yaml` must include hooks for: `terraform fmt`, `terraform validate`, `tflint`, `detect-secrets` or `gitleaks`.
- Pre-commit hooks must be versioned and pinned to a specific tag or SHA.

## Security Scanning Rules

- Checkov must scan all `.tf` files and fail on `HIGH` or `CRITICAL` severity findings unless explicitly suppressed with a justification comment.
- Trivy must scan for misconfigurations and secrets; fail on `HIGH` or `CRITICAL`.
- Gitleaks must run on every push and PR to detect secrets in commit history.
- TFLint must use the `terraform` ruleset and the `aws` plugin.

## Repository Structure Rules

- The repository root must contain: `README.md`, `.gitignore`, `.pre-commit-config.yaml`, `.tflint.hcl`, `trivy.yaml`.
- An `examples/` directory with `main.tf`, `variables.tf`, and `README.md` is mandatory.
- An `.amazonq/rules/` directory with at least one ruleset file is mandatory.
- Terraform state files (`*.tfstate`, `*.tfstate.backup`) must never be committed.
