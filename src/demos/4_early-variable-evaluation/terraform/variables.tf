variable "environment" {
  description = "Target environment. Selects the backend state path."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "tf_person" {
  description = "Person name for module source."
  type        = string
  default     = "linda"

  # Step 3: uncomment to make var usable in module source
  # const = true

  validation {
    condition     = contains(["linda", "philipp"], var.tf_person)
    error_message = "tf_person must be 'linda' or 'philipp'."
  }
}
