# variables.tf - root
variable "subscription_id" {
  description = "Azure subscription id"
  type        = string
  default     = "<subscription_id>"
}

variable "tenant_id" {
  description = "Azure tenant id"
  type        = string
  default     = "<tenant_id>"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Common resource name prefix"
  type        = string
  default     = "acmeprod"
}

variable "rg_name" {
  description = "Primary resource group name for infra"
  type        = string
  default     = "rg-acme-prod"
}

# ACR
variable "acr_name" {
  description = "Name of ACR (must be globally unique)"
  type        = string
  default     = "acmeprodacr" # change if conflicts
}

# SSH key
variable "ssh_public_key_path" {
  description = "Path to SSH public key used by AKS nodes (e.g., ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# AKS sizing & autoscaler
variable "aks_node_count" {
  description = "Initial node count for the system node pool"
  type        = number
  default     = 3
}

variable "aks_node_vm_size" {
  description = "VM size for AKS node pool"
  type        = string
  default     = "Standard_DC2s_v3"
}

variable "aks_node_min_count" {
  description = "Min nodes for autoscaler"
  type        = number
  default     = 2
}

variable "aks_node_max_count" {
  description = "Max nodes for autoscaler"
  type        = number
  default     = 8
}

variable "api_server_authorized_ip_ranges" {
  description = "Optional list of IP ranges allowed to access AKS API server. Leave empty for public access."
  type        = list(string)
  default     = []
}

