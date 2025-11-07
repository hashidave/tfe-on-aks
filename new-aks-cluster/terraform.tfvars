# --- Common --- #
friendly_name_prefix = "sandbox" # typically either environment (e.g. 'sandbox', 'prod') or team name

create_resource_group = false
resource_group_name  = "tfe"
location             = "eastus"
common_tags = {
  App         = "TFE"
  Environment = "<sandbox>"
  Owner       = "<TeamName>"
}

# --- TFE config settings --- #
tfe_fqdn                   = "tfe.dave.com"
create_helm_overrides_file = true # set to `false` after initial deploy

# --- Networking --- #
vnet_id          = "/subscriptions/07b3a4df-8d2f-4110-9150-29ca2db399f0/resourceGroups/tfe/providers/Microsoft.Network/virtualNetworks/tfe-net"
tfe_lb_subnet_id = "/subscriptions/07b3a4df-8d2f-4110-9150-29ca2db399f0/resourceGroups/tfe/providers/Microsoft.Network/virtualNetworks/tfe-net/subnets/default"
aks_subnet_id    = "/subscriptions/07b3a4df-8d2f-4110-9150-29ca2db399f0/resourceGroups/tfe/providers/Microsoft.Network/virtualNetworks/tfe-net/subnets/akssubnet"
db_subnet_id     = "/subscriptions/07b3a4df-8d2f-4110-9150-29ca2db399f0/resourceGroups/tfe/providers/Microsoft.Network/virtualNetworks/tfe-net/subnets/dbsubnet"
redis_subnet_id  = "/subscriptions/07b3a4df-8d2f-4110-9150-29ca2db399f0/resourceGroups/tfe/providers/Microsoft.Network/virtualNetworks/tfe-net/subnets/redissubnet"

# --- AKS --- #
create_aks_cluster                  = true
aks_kubernetes_version              = "1.33.3"
aks_api_server_authorized_ip_ranges = ["10.0.0.0/16", "23.128.56.90/32"] # CIDR ranges of clients/workstations managing AKS cluster
aks_default_node_pool_vm_size       = "Standard_A4_v2"
create_aks_tfe_node_pool            = true
aks_tfe_node_pool_vm_size           = "Standard_d8ds_v4"

# --- Database --- #
tfe_database_password_keyvault_id          = "/subscriptions/07b3a4df-8d2f-4110-9150-29ca2db399f0/resourceGroups/tfe/providers/Microsoft.KeyVault/vaults/tfe-keyvault" # ID of Azure Key Vault containing tfe_database_password secret
tfe_database_password_keyvault_secret_name = "tfe-secret"

# --- Object Storage --- #

storage_account_ip_allow = ["23.128.56.90"] # IP address(es) of clients/workstations managing TFE deployment (without subnet masks)
