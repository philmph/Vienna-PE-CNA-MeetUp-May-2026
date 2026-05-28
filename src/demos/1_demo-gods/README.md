# Tribute To The Demo Gods

Mandatory tribute to the demo gods before running any real demos.

## What this demo shows

Absolutely nothing.

## Prerequisites

- OpenTofu Version 1.8.0 (released 08/2024)
- Terraform Version 1.8.0 (released 04/2024)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in
- An Azure Subscription

## Run It

### OpenTofu

```sh
az login

tofu init
tofu apply -auto-approve
```

### Cleanup / Reset

```sh
[ "$(basename "$PWD")" = "1_demo-gods" ] && tofu destroy -auto-approve
[ "$(basename "$PWD")" = "1_demo-gods" ] && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```

## Notes

- This is mandatory when presenting
