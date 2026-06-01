# Early Variable Evaluation

Variables usable in `backend {}` and `module source` — OpenTofu fully, Terraform partially.

Lead by OpenTofu (08/2024) vs. Terraform (04/2026) by 20 months.

## What this demo shows

| Feature                                      | OpenTofu 1.8+ | Terraform 1.15+ |
| -------------------------------------------- | ------------- | --------------- |
| `var.*` in `backend {}`                      | ✅            | ❌              |
| `module source` with regular `var.*`         | ✅            | ❌              |
| `module source` with static local            | ✅            | ✅              |
| `module source` with `const = true` variable | ❌            | ✅              |

Terraform 1.15 ("dynamic sources") only supports static locals and `const = true` variables in `module source` — regular `var.*` references are rejected. Backend configuration remains static at all Terraform versions. OpenTofu does not need `const = true` because all variables are available in early evaluation.

## Prerequisites

- OpenTofu Version 1.8.0 (released 08/2024)
- Terraform Version 1.15.0 (released 04/2026)

## Run It

### OpenTofu

```sh
cd opentofu

# Step 1 — Backend variables: var.environment selects the state path
tofu init -var 'environment=dev' -reconfigure
tofu apply -auto-approve -var 'environment=dev'
cat output/marker-dev.txt

# Switch to prod — different state path, no wrapper script needed
tofu init -var 'environment=prod' -reconfigure
tofu apply -auto-approve -var 'environment=prod'
cat output/marker-prod.txt

# Step 2 — var in module source: tofu_person selects the module
tofu init -var 'tofu_person=linda'
tofu apply -auto-approve -var 'tofu_person=linda'
# var.tofu_person = "linda" → loads ../modules/hello-linda

tofu init -var 'tofu_person=philipp'
tofu apply -auto-approve -var 'tofu_person=philipp'
# var.tofu_person = "philipp" → loads ../modules/hello-philipp
```

### Terraform

```sh
cd ../terraform

# Step 1 — Dynamic backend fails: var not supported in backend {}
terraform init -var 'environment=dev' -reconfigure
# Error: Variables may not be used here

# In versions.tf: comment out the var backend block, uncomment the static backend block
terraform init -backend-config='path=states/dev/terraform.tfstate' -reconfigure

# Step 2 — Regular var in module source fails
terraform init -backend-config='path=states/dev/terraform.tfstate' -var 'tf_person=linda'
terraform apply -auto-approve -var 'tf_person=linda'
# Error: Variables may not be used here

# Step 3 — In variables.tf: uncomment const = true
terraform init -backend-config='path=states/dev/terraform.tfstate' -var 'tf_person=philipp'
terraform apply -auto-approve -var 'tf_person=philipp'
# var.tf_person = "philipp" (const = true) → loads ../modules/hello-philipp
cat output/marker-dev.txt

# Step 4 — In main.tf: swap source to the static local line
terraform apply -auto-approve
# local.tf_person = "hello-linda" (static) → loads ../modules/hello-linda
cat output/marker-dev.txt
```

### Cleanup / Reset

```sh
[ "$(basename "$PWD")" = "4_early-variable-evaluation" ] && rm -rf opentofu/.terraform opentofu/.terraform.lock.hcl opentofu/output opentofu/states terraform/.terraform terraform/.terraform.lock.hcl terraform/output terraform/states

# Reset modified files
(cd terraform && git restore main.tf variables.tf versions.tf)
```

## Notes

- `states/dev/` and `states/prod/` are created as separate state files in each subfolder's working directory — the OpenTofu showcase.
- `-reconfigure` is required when switching environments because the backend path changes.
- Terraform 1.15 rejects regular `var.*` in `module source` — only static locals and `const = true` variables work.
- `const = true` is a Terraform 1.15 variable attribute that marks the variable as a compile-time constant, enabling it in `module source`. Not available in OpenTofu — not needed, since all variables work there.
- Both `backend {}` variables (all versions) and dynamic locals in `module source` (1.15) remain unsupported in Terraform.
