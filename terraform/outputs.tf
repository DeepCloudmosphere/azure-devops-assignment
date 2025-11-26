output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = module.aks.aks_name
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}