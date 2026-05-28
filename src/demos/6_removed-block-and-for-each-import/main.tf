data "azurerm_client_config" "current" {}

locals {
  location = "westeurope"

  resource_groups = [
    "rg-fluffy-panda",
    "rg-sneaky-fox",
    "rg-happy-otter",
    "rg-lazy-koala",
    "rg-brave-penguin",
    "rg-clever-wolf",
    "rg-silly-llama",
    "rg-grumpy-cat",
    "rg-witty-capybara",
    "rg-tiny-hedgehog",
  ]
}

# Step 1: apply with this block active
resource "azurerm_resource_group" "this" {
  for_each = toset(local.resource_groups)

  name     = each.key
  location = local.location

  lifecycle {
    ignore_changes = [tags]
  }
}

# Step 2: comment out the resource block above, uncomment this block
# removed {
#   from = azurerm_resource_group.this

#   lifecycle {
#     destroy = false
#   }
# }

# Step 3: uncomment the resource block (Step 1) and this block
# import {
#   for_each = toset(local.resource_groups)

#   to = azurerm_resource_group.this[each.key]
#   id = provider::azurerm::normalise_resource_id("/suBsCriptIOns/${data.azurerm_client_config.current.subscription_id}/resoURceGroUps/${each.key}")
# }
