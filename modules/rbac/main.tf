variable "scope" {}
variable "admin_group_object_id" {}

resource "azurerm_role_assignment" "reader" {
  scope                = var.scope
  role_definition_name = "Reader"
  principal_id         = var.admin_group_object_id
}

resource "azurerm_role_assignment" "keyvault_admin" {
  scope                = var.scope
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_group_object_id
}