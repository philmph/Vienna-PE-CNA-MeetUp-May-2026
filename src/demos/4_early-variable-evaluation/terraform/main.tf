locals {
  tf_person = "hello-philipp"
}

resource "local_file" "marker" {
  filename = "${path.module}/output/marker-${var.environment}.txt"
  content  = "active environment: ${var.environment}\n"
}

# More info at https://github.com/hashicorp/terraform/releases/tag/v1.15.0
# The module source can only reference constant input variables and local values.

# Step 2 / Step 3: source uses var.tf_person (fails without const = true, works with it)
# module "hello_world_terraform" {
#   source = "../modules/hello-${var.tf_person}"

#   # Step 4: swap to this static local source
#   # source = "../modules/${local.tf_person}"
# }
