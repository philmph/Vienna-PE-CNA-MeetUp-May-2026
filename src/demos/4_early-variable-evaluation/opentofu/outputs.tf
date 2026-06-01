output "module_message" {
  value = var.tofu_person != "person" ? module.hello_world_opentofu.message : "No person specified."
}
