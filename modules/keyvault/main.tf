variable "name_prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "tenant_id" {}
variable "private_endpoint_subnet_id" {}
variable "private_dns_zone_id" {}
variable "log_analytics_workspace_id" {}
variable "tags" {}

resource "azurerm_key_vault" "kv" {
  name                          = replace("${var.name_prefix}-kv", "-", "")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = true
  tags                          = var.tags
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${var.name_prefix}-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "${var.name_prefix}-kv-diag"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}