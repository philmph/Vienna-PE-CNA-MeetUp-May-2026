# Ephemeral Resources And Values

Secret never lands in state — on either the write path or the read path.

Lead by Terraform (11/2024) vs. OpenTofu (01/2026) by 14 months.

## What this demo shows

| Declaration                                        | Kind                      | In state?                         |
| -------------------------------------------------- | ------------------------- | --------------------------------- |
| `variable "secret_value"` (`ephemeral = true`)     | ephemeral variable        | no                                |
| `azurerm_key_vault_secret` + `value_wo`            | write-only attribute      | no (`value_wo` absent from state) |
| `ephemeral "azurerm_key_vault_secret"`             | ephemeral resource (read) | no                                |
| `azurerm_resource_group`                           | normal resource           | yes                               |
| `azurerm_key_vault`                                | normal resource           | yes                               |
| `azurerm_role_assignment`                          | normal resource           | yes                               |
| `azurerm_key_vault_secret` (resource entry itself) | normal resource           | yes (IDs only, not the value)     |

## Prerequisites

- OpenTofu Version 1.11.0 (released 01/2026)
- Terraform Version 1.10.0 (released 11/2024)
- azurerm provider >= 4.14
- Azure subscription + `az login`

## Run It

### OpenTofu

```sh
tofu init

# Step 1 — Apply: write path only (value_wo never lands in state)
tofu apply -auto-approve -var 'secret_value=VerySecure' -var 'secret_version=1'

# Inspect state — value_wo is absent from the azurerm_key_vault_secret entry
cat terraform.tfstate | jq '.resources[] | select(.type == "azurerm_key_vault_secret")'

# Step 2 — In main.tf: uncomment the ephemeral block
tofu apply -auto-approve -var 'secret_value=VerySecure' -var 'secret_version=1'

# Inspect state — ephemeral resource does not appear in state
cat terraform.tfstate | jq '.resources[] | select(.type == "azurerm_key_vault_secret")'

# Step 3 — In main.tf: comment out the ephemeral block, uncomment the data source block
tofu apply -auto-approve -var 'secret_value=VerySecure' -var 'secret_version=1'

# Inspect state — data source value IS in state (contrast with ephemeral)
cat terraform.tfstate | jq '.resources[] | select(.type == "azurerm_key_vault_secret")'
```

### Terraform

```sh
terraform init

# Step 1 — Apply: write path only (value_wo never lands in state)
terraform apply -auto-approve -var 'secret_value=VerySecure' -var 'secret_version=1'

# Inspect state — value_wo is absent from the azurerm_key_vault_secret entry
cat terraform.tfstate | jq '.resources[] | select(.type == "azurerm_key_vault_secret")'

# Step 2 — In main.tf: uncomment the ephemeral block
terraform apply -auto-approve -var 'secret_value=VerySecure' -var 'secret_version=1'

# Inspect state — ephemeral resource does not appear in state
cat terraform.tfstate | jq '.resources[] | select(.type == "azurerm_key_vault_secret")'

# Step 3 — In main.tf: comment out the ephemeral block, uncomment the data source block
terraform apply -auto-approve -var 'secret_value=VerySecure' -var 'secret_version=1'

# Inspect state — data source value IS in state (contrast with ephemeral)
cat terraform.tfstate | jq '.resources[] | select(.type == "azurerm_key_vault_secret")'
```

### Cleanup / Reset

```sh
[ "$(basename "$PWD")" = "5_ephemeral-resources" ] && tofu destroy -auto-approve
[ "$(basename "$PWD")" = "5_ephemeral-resources" ] && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup

[ "$(basename "$PWD")" = "5_ephemeral-resources" ] && git restore main.tf
```

## Notes

- `value_wo` is write-only — never returned by the provider; state has name and ID but no value.
- `value_wo_version` is the change-detection trigger — increment it to signal the secret must be re-written.
- `depends_on` on the secret ensures the role assignment propagates before first use.
- KV name: `kv` + 8 random chars. `purge_protection_enabled = false` required for clean `destroy`.
