locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source              = "./modules/network"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

module "keyvault" {
  source                         = "./modules/keyvault"
  name_prefix                    = local.name_prefix
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  private_endpoint_subnet_id     = module.network.private_endpoint_subnet_id
  private_dns_zone_id            = module.network.keyvault_private_dns_zone_id
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
  tags                           = local.common_tags
}

module "storage" {
  source                         = "./modules/storage"
  name_prefix                    = local.name_prefix
  location                       = var.location
  resource_group_name            = azurerm_resource_group.rg.name
  private_endpoint_subnet_id     = module.network.private_endpoint_subnet_id
  private_dns_zone_id            = module.network.blob_private_dns_zone_id
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
  tags                           = local.common_tags
}

module "policy" {
  source              = "./modules/policy"
  resource_group_id   = azurerm_resource_group.rg.id
  location            = var.location
}

module "rbac" {
  source                = "./modules/rbac"
  scope                 = azurerm_resource_group.rg.id
  admin_group_object_id = var.admin_group_object_id
}

data "azurerm_client_config" "current" {}