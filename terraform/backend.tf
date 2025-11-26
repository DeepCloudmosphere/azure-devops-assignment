terraform {
  backend "azurerm" {
    resource_group_name  = var.backend_rg
    storage_account_name = var.backend_sa_name
    container_name       = var.backend_container
    key                  = "${var.backend_key_prefix}/${terraform.workspace}.tfstate"
  }
}
