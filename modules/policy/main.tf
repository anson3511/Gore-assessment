variable "resource_group_id" {}
variable "location" {}

resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "require-tags"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
  display_name         = "Require a tag on resources"

  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749"
  display_name         = "Deny public IP creation"
}