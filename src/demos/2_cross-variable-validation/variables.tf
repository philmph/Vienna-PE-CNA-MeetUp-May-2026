variable "min_replicas" {
  description = "Lower bound for the autoscaler."
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Upper bound for the autoscaler."
  type        = number
  default     = 3

  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas (${var.max_replicas}) must be >= min_replicas (${var.min_replicas})."
  }
}

variable "enable_notifications" {
  description = "Set to true to enable notifications. Requires notification_email to be set."
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "E-mail address for notifications. Required when enable_notifications is true."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = !var.enable_notifications || var.notification_email != ""
    error_message = "notification_email must be set when enable_notifications is true."
  }
}
