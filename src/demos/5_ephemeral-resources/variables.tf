variable "secret_value" {
  description = "The secret to store in Key Vault. Marked ephemeral — never written to state or saved plan files. A default is provided for demo convenience; supply a real value via -var or TF_VAR_secret_value in production."
  type        = string
  ephemeral   = true
  sensitive   = true
}

variable "secret_version" {
  description = "Increment to rotate the secret value. Changing this triggers a re-write of the Key Vault secret via value_wo_version."
  type        = number
}
