variable "state_passphrase" {
  type        = string
  sensitive   = true
  description = "Passphrase used to derive the state encryption key via PBKDF2."
}
