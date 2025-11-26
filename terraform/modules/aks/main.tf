data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-aks"

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.node_vm_size
    max_pods   = 110
    type       = "VirtualMachineScaleSets"
    auto_scaling_enabled = true
    min_count  = var.node_min_count
    max_count  = var.node_max_count
    vnet_subnet_id = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file(var.ssh_public_key_path)
    }
  }

  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }
}

# expose some outputs about identity
resource "null_resource" "wait_for_identity" {
  # used to ensure managed identity object id is populated
  triggers = {
    principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    kubelet_id   = tostring(azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id)
  }
}

# role assignment to allow AKS Kubelet to pull images from ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [null_resource.wait_for_identity]
}
