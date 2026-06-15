variable "name_prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "tags" {}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.name_prefix}-log"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}