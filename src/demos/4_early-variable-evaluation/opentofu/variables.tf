variable "environment" {
  description = "Target environment. Selects the backend state path."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "tofu_person" {
  description = "Person name for OpenTofu module source."
  type        = string
  default     = "person"

  validation {
    condition     = contains(["person", "linda", "philipp"], var.tofu_person)
    error_message = "tofu_person must be 'linda' or 'philipp'."
  }
}
