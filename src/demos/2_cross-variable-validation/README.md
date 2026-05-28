# Cross Variable Validation

`validation { condition }` blocks that reference other input variables — enforced at plan time before any resource is touched.

Lead by Terraform (06/2024) vs. OpenTofu (01/2025) by 7 months.

## What this demo shows

Two validation patterns:

1. **Numeric bound** — `max_replicas` must be `>= min_replicas`. The error message interpolates both values, making the constraint self-evident on screen.
2. **Conditional requirement** — `notification_email` is optional by default but becomes mandatory when `enable_notifications = true`. Setting the flag without the email fails at plan time.

## Prerequisites

- OpenTofu Version 1.9.0 (released 01/2025)
- Terraform Version 1.9.0 (released 06/2024)

## Run It

### OpenTofu

```sh
tofu init

# Happy path — defaults min=1 max=3, notifications off
tofu apply -auto-approve
cat output/scaling.txt
cat output/notifications.txt

# Trigger numeric validation failure — min=5 exceeds default max=3
tofu apply -auto-approve -var 'min_replicas=5'

# Fix both — succeeds
tofu apply -auto-approve -var 'min_replicas=2' -var 'max_replicas=10'
cat output/scaling.txt

# Trigger conditional requirement failure — flag set but email missing
tofu apply -auto-approve -var 'enable_notifications=true'

# Provide both — succeeds
tofu apply -auto-approve -var 'enable_notifications=true' -var 'notification_email=ops@example.com'
cat output/notifications.txt
```

### Terraform

```sh
terraform init

# Happy path
terraform apply -auto-approve
cat output/scaling.txt
cat output/notifications.txt

# Trigger numeric validation failure
terraform apply -auto-approve -var 'min_replicas=5'

# Fix both
terraform apply -auto-approve -var 'min_replicas=2' -var 'max_replicas=10'
cat output/scaling.txt

# Trigger conditional requirement failure
terraform apply -auto-approve -var 'enable_notifications=true'

# Provide both
terraform apply -auto-approve -var 'enable_notifications=true' -var 'notification_email=ops@example.com'
cat output/notifications.txt
```

### Cleanup / Reset

```sh
[ "$(basename "$PWD")" = "2_cross-variable-validation" ] && rm -rf .terraform .terraform.lock.hcl output terraform.tfstate terraform.tfstate.backup
```

## Notes

- Validation fires at plan time — no infrastructure is created before the error is raised.
- Numeric bound: error interpolates both values — `max_replicas (3) must be >= min_replicas (5)`.
- Conditional requirement: fails at plan time only when `enable_notifications = true` and `notification_email` is empty; the condition short-circuits when the flag is off.
