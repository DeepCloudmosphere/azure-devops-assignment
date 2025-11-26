variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }

variable "ssh_public_key_path" { type = string }
variable "node_count" { type = number }
variable "node_vm_size" { type = string }
variable "node_min_count" { type = number }
variable "node_max_count" { type = number }

variable "vnet_subnet_id" { type = string }

variable "log_analytics_workspace_id" { type = string }
variable "acr_registry_id" { type = string }

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}