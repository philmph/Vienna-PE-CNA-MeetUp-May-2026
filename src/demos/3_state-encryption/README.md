# State Encryption

Native AES-GCM encryption of the state file at rest using a PBKDF2 passphrase-derived key.

Only implemented by OpenTofu (04/2024)

## What this demo shows

`terraform.tfstate` is an opaque encrypted blob after the first apply — not readable JSON. OpenTofu decrypts it transparently on every subsequent command when the correct passphrase is provided. The `encryption {}` block lives in `versions.tf`. Using a different passphrase fails to decrypt the existing state, proving the key binding.

## Prerequisites

- OpenTofu Version 1.7.0 (released 04/2024)
- Terraform Version — no native equivalent for this feature

## Run It

### OpenTofu

```sh
tofu init -var 'state_passphrase=myVerySecurePassphrase'

# Apply with the first passphrase
tofu apply -auto-approve -var 'state_passphrase=myVerySecurePassphrase'
cat terraform.tfstate
cat output/hello.txt

# Re-apply with a DIFFERENT passphrase — fails to decrypt existing state
tofu apply -auto-approve -var 'state_passphrase=myVeryInsecurePassphrase'
```

### Terraform

State encryption is not available in Terraform. There is no native equivalent for the `encryption {}` block. External workarounds (encrypted backends, sops, wrapper scripts) are required.

### Cleanup / Reset

```sh
[ "$(basename "$PWD")" = "3_state-encryption" ] && rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup output
```

## Notes

- The second `tofu apply` errors with `Failed to decrypt state` — expected, proving the key binding.
- `cat terraform.tfstate` shows an opaque binary blob; `cat output/hello.txt` is plain text — encryption is at the state layer only.
