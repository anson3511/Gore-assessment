variable "name_prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "private_endpoint_subnet_id" {}
variable "private_dns_zone_id" {}
variable "log_analytics_workspace_id" {}
variable "tags" {}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage" {
  name                            = replace("${var.name_prefix}${random_string.suffix.result}", "-", "")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${var.name_prefix}-storage-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-storage-psc"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_diag" {
  name                       = "${var.name_prefix}-storage-diag"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "Transaction"
    enabled  = true
  }
}