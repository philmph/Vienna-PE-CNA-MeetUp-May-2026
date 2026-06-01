resource "local_file" "scaling_config" {
  filename = "${path.module}/output/scaling.txt"
  content  = "min=${var.min_replicas}\nmax=${var.max_replicas}\n"
}

resource "local_file" "notification_config" {
  filename = "${path.module}/output/notifications.txt"
  content  = "enabled=${var.enable_notifications}\nemail=${var.notification_email}\n"
}
