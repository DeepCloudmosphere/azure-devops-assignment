output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
output "kube_admin_username" {
  value = "azureuser"
}