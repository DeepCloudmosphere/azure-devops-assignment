locals {
  name_prefix = var.prefix
}

resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
  tags = {
    environment = "prod"
    owner       = "devops-team"
  }
}

module "network" {
  source = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  prefix              = local.name_prefix
}

module "log_analytics" {
  source = "./modules/log_analytics"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  prefix              = local.name_prefix
}

module "acr" {
  source = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  prefix              = local.name_prefix
  acr_name            = var.acr_name
  sku                 = "Standard"
}

module "aks" {
  source = "./modules/aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  prefix              = local.name_prefix

  ssh_public_key_path                 = var.ssh_public_key_path
  node_count                          = var.aks_node_count
  node_vm_size                        = var.aks_node_vm_size
  node_min_count                      = var.aks_node_min_count
  node_max_count                      = var.aks_node_max_count
  api_server_authorized_ip_ranges     = var.api_server_authorized_ip_ranges

  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  acr_registry_id           = module.acr.acr_id

  vnet_subnet_id            = module.network.aks_subnet_id
}

module "keyvault" {
  source = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  prefix              = local.name_prefix

  aks_managed_identity_object_id = module.aks.kubelet_identity_object_id
}
