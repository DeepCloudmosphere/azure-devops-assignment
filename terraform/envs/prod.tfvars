subscription_id = "ed205901-4c9d-4434-9941-02372033ca67"
tenant_id       = "42cad5ed-9bfd-4a40-8cd1-f32af48fe156"

location = "eastus"
prefix   = "acmeprod"
rg_name  = "rg-acme-prod"

acr_name            = "acmeprodacr" # must be globally unique; change if needed
ssh_public_key_path = "~/.ssh/id_rsa.pub"

aks_node_count     = 3
aks_node_vm_size = "Standard_DC2s_v3"
aks_node_min_count = 2
aks_node_max_count = 8

# If you want to restrict API server access, set your public IP in CIDR form, e.g. ["x.x.x.x/32"]
api_server_authorized_ip_ranges = []