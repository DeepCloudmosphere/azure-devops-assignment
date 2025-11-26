data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                     = "${var.prefix}-kv"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
  tags                     = { environment = "prod" }
}

resource "azurerm_key_vault_access_policy" "aks_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.aks_managed_identity_object_id
  secret_permissions = [
    "Get",
    "List"
  ]
}