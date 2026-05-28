resource "local_file" "marker" {
  filename = "${path.module}/output/marker-${var.environment}.txt"
  content  = "active environment: ${var.environment}\n"
}

module "hello_world_opentofu" {
  source = "../modules/hello-${var.tofu_person}"
}
