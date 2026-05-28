# Removed Block + for_each in Import

Declaratively remove resources from state, then re-import them in bulk — all without touching the underlying infrastructure.

`removed` block: OpenTofu (04/2024) · Terraform (01/2024) — both at minor 1.7, Terraform first by ~3 months.
`for_each` in `import`: OpenTofu (04/2024) · Terraform (01/2024) — parity.

## What this demo shows

Ten Azure resource groups are created via `for_each`. A single `removed` block (referencing the entire `for_each` resource, no key needed) then drops all ten instances from state at once — leaving the resource groups alive in Azure. The removal is a config change, reviewable in a PR, not an out-of-band `state rm` command.

| Step | Action                                    | State      | Azure              |
| ---- | ----------------------------------------- | ---------- | ------------------ |
| 1    | `apply` with `resource` block             | 10 entries | 10 RGs created     |
| 2    | `apply` with `removed` block              | 0 entries  | 10 RGs still exist |
| 3    | `apply` with `resource` + `import` blocks | 10 entries | unchanged          |

## Prerequisites

- OpenTofu Version 1.7.0 (released 04/2024)
- Terraform Version 1.7.0 (released 01/2024)
- Azure subscription with permissions to create Resource Groups
- Azure CLI logged in (`az login`) or service principal configured

## Run It

### OpenTofu

```sh
tofu init

# Step 1 — Create 10 resource groups
tofu apply -auto-approve

# Show all 10 in state
tofu state list

# Step 2 — In main.tf: comment out the resource block, uncomment the removed block
tofu plan

# Look for: "will be removed from the Terraform state" + "(destroy = false)"
tofu apply -auto-approve

# Show empty state — RGs are gone from state but still exist in Azure
tofu state list

# Step 3 — In main.tf: uncomment the resource block (Step 1) and the import block
tofu plan

# Look for: "10 to import, 0 to add, 0 to change"
tofu apply -auto-approve

# Show all 10 back in state
tofu state list
```

### Terraform

```sh
terraform init

# Step 1 — Create 10 resource groups
terraform apply -auto-approve

# Show all 10 in state
terraform state list

# Step 2 — In main.tf: comment out the resource block, uncomment the removed block
terraform plan

# Look for: "will be removed from the Terraform state" + "(destroy = false)"
terraform apply -auto-approve

# Show empty state — RGs are gone from state but still exist in Azure
terraform state list

# Step 3 — In main.tf: uncomment the resource block (Step 1) and the import block
terraform plan

# Look for: "10 to import, 0 to add, 0 to change"
terraform apply -auto-approve

# Show all 10 back in state
terraform state list
```

### Cleanup / Reset

```sh
# If still at Step 1 (RGs in state): destroy via Terraform/OpenTofu
[ "$(basename "$PWD")" = "6_removed-block-and-for-each-import" ] && tofu destroy -auto-approve

# If already at Step 2 (RGs removed from state, still in Azure): delete via az CLI
[ "$(basename "$PWD")" = "6_removed-block-and-for-each-import" ] && for rg in rg-fluffy-panda rg-sneaky-fox rg-happy-otter rg-lazy-koala rg-brave-penguin \
          rg-clever-wolf rg-silly-llama rg-grumpy-cat rg-witty-capybara rg-tiny-hedgehog; do
  az group delete --name "$rg" --yes --no-wait
done

# Remove local files and reset main.tf
[ "$(basename "$PWD")" = "6_removed-block-and-for-each-import" ] && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

[ "$(basename "$PWD")" = "6_removed-block-and-for-each-import" ] && git restore main.tf
```

## Notes

- `from = azurerm_resource_group.this` (without a key) removes all `for_each` instances in one block.
- The Step 3 `import` block uses `provider::azurerm::normalise_resource_id(...)` to return the canonical resource ID Azure expects — avoids import failures from subscription ID or casing drift.
- Both `removed` and `import` blocks are one-shot directives; they can be deleted after a successful apply.
- Equivalent to running `terraform state rm` ten times — but tracked in version control and reviewable in a PR.
- `destroy = false` is the critical line — omit or set to `true` and the infrastructure is deleted.
