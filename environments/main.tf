#######################################################
#           GROUPS
#######################################################
module "resource_group" {
  source   = "../modules/resources/groups"
  name     = "${local.name_prefix}-rg"
  location = var.region
  tags     = local.common_tags
}

#######################################################
#           NETWORK
#######################################################
module "vnet" {
  source             = "../modules/resources/network/vnet"
  region             = var.region
  vnet_name          = "${local.name_prefix}-vnet"
  vnet_rg_name       = module.resource_group.az_rg_name
  vnet_address_space = ["10.1.0.0/16"]

  vnet_resource_tags = local.common_tags
}

module "private_sbn" {
  source               = "../modules/resources/network/subnet"
  subnet_name          = "sbn-private"
  virtual_network_name = module.vnet.az_vnet_name
  resource_group_name  = module.resource_group.az_rg_name
  subnet_cidr_list     = ["10.1.0.0/24"]
  depends_on           = [module.vnet]
}
module "public_sbn" {
  source               = "../modules/resources/network/subnet"
  subnet_name          = "sbn-public"
  virtual_network_name = module.vnet.az_vnet_name
  resource_group_name  = module.resource_group.az_rg_name
  subnet_cidr_list     = ["10.1.1.0/24"]
  depends_on           = [module.vnet]

}
module "sqlserver_sbn" {
  source               = "../modules/resources/network/subnet"
  subnet_name          = "sbn-sqlserver"
  virtual_network_name = module.vnet.az_vnet_name
  resource_group_name  = module.resource_group.az_rg_name
  subnet_cidr_list     = ["10.1.2.0/24"]
  subnet_srv_endpoints = ["Microsoft.Sql"]
  subnet_delegation = {
    managedinstancedelegation = [
      {
        name    = "Microsoft.Sql/managedInstances"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
      }
    ]
  }
  depends_on = [module.vnet]

}
module "cosmos_mongo_sbn" {
  source               = "../modules/resources/network/subnet"
  subnet_name          = "sbn-cosmos-mongo"
  virtual_network_name = module.vnet.az_vnet_name
  resource_group_name  = module.resource_group.az_rg_name
  subnet_cidr_list     = ["10.1.3.0/24"]
  subnet_srv_endpoints = ["Microsoft.AzureCosmosDB"]
  depends_on           = [module.vnet]
}


# PUBLIC IP ###########################################################
resource "azurerm_public_ip" "pip" {
  name                = "${local.name_prefix}-publicIp-appgw"
  location            = module.resource_group.az_rg_location
  resource_group_name = module.resource_group.az_rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]

  tags = local.common_tags
}

resource "azurerm_nat_gateway" "ngw" {
  name                    = "${local.name_prefix}-nat-gateway"
  location                = module.resource_group.az_rg_location
  resource_group_name     = module.resource_group.az_rg_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.ngw.id
  public_ip_address_id = azurerm_public_ip.pip.id
}

# Create Static Public IP Address to be used by Nginx Ingress
# resource "azurerm_public_ip" "nginx_ingress_pip" {
#   name                = "nginx-ingress-pip"
#   resource_group_name = module.resource_group.az_rg_name
#   location            = module.resource_group.az_rg_location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   domain_name_label   = "${local.pet}doit"

#   tags = local.common_tags
# }

# SECURITY GROUP ###########################################################

resource "azurerm_network_security_group" "private" {
  name                = "private-sec-group"
  location            = module.resource_group.az_rg_location
  resource_group_name = module.resource_group.az_rg_name
}
resource "azurerm_network_security_group" "public" {
  name                = "public-sec-group"
  location            = module.resource_group.az_rg_location
  resource_group_name = module.resource_group.az_rg_name
}
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = module.private_sbn.subnet_id
  network_security_group_id = azurerm_network_security_group.private.id
}
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = module.public_sbn.subnet_id
  network_security_group_id = azurerm_network_security_group.public.id
}

# SQL SERVER DATABASE NETWORK CONFIG ###########################################################
resource "azurerm_network_security_group" "sql_server" {
  name                = "dbs-sec-group"
  location            = module.resource_group.az_rg_location
  resource_group_name = module.resource_group.az_rg_name
}

# ADDING SQLSERVER RULES #
resource "azurerm_network_security_rule" "allow_management_inbound" {
  name                        = "allow_management_inbound"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["9000", "9003", "1438", "1440", "1452"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "allow_misubnet_inbound" {
  name                        = "allow_misubnet_inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "allow_health_probe_inbound" {
  name                        = "allow_health_probe_inbound"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "allow_tds_inbound" {
  name                        = "allow_tds_inbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "deny_all_inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "allow_management_outbound" {
  name                        = "allow_management_outbound"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443", "12000"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "allow_misubnet_outbound" {
  name                        = "allow_misubnet_outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}

resource "azurerm_network_security_rule" "deny_all_outbound" {
  name                        = "deny_all_outbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.resource_group.az_rg_name
  network_security_group_name = azurerm_network_security_group.sql_server.name
}


resource "azurerm_subnet_network_security_group_association" "dbs_secg_asso" {
  subnet_id                 = module.sqlserver_sbn.subnet_id
  network_security_group_id = azurerm_network_security_group.sql_server.id
}

# ROUTE TABLE ###########################################################

resource "azurerm_route_table" "dbs_route_table" {
  name                          = "routetable-db-mi"
  location                      = module.resource_group.az_rg_location
  resource_group_name           = module.resource_group.az_rg_name
  disable_bgp_route_propagation = false
  tags                          = local.common_tags
  depends_on                    = [module.vnet]
}

resource "azurerm_subnet_route_table_association" "sqlserver" {
  subnet_id      = module.sqlserver_sbn.subnet_id
  route_table_id = azurerm_route_table.dbs_route_table.id
}


#######################################################
#           KEY VAULT
#######################################################
#Create KeyVault ID
# resource "random_id" "kvname" {
#   byte_length = 5
#   prefix      = "keyvault"
# }

# data "azurerm_client_config" "client_config" {}
# resource "azurerm_key_vault" "kv" {
#   depends_on                  = [module.resource_group.az_rg_name]
#   name                        = random_id.kvname.hex
#   location                    = module.resource_group.az_rg_location
#   resource_group_name         = module.resource_group.az_rg_name
#   enabled_for_disk_encryption = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false
#   sku_name                    = "standard"
#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id
#     key_permissions = [
#       "get",
#     ]
#     secret_permissions = [
#       "get", "backup", "delete", "list", "purge", "recover", "restore", "set",
#     ]
#     storage_permissions = [
#       "get",
#     ]
#   }
# }

# Password creation example
#Create KeyVault VM password
# resource "random_password" "vmpassword" {
#   length = 20
#   special = true
# }

# #Create Key Vault Secret
# resource "azurerm_key_vault_secret" "vmpassword" {
#   name         = "vmpassword"
#   value        = random_password.vmpassword.result
#   key_vault_id = azurerm_key_vault.kv1.id
#   depends_on = [ azurerm_key_vault.kv1 ]
# }


#######################################################
#           DATABASE
#######################################################

# module "sql_server_mi" {
#   source              = "../modules/resources/sqlserver"
#   sql_server_name     = "${local.pet}sqlserver"
#   resource_group_name = module.resource_group.az_rg_name
#   location            = module.resource_group.az_rg_location
#   subnet_id           = module.sqlserver_sbn.subnet_id

#   storage_size_in_gb  = 32
#   virtual_cores_count = 4
#   // FIXME generate username and password in secure way
#   admin_username = "mradministrator"
#   admin_password = "thisIsDog11"

#   sql_tags = local.common_tags
# }


# module "cosmos_mongodb" {
#   source                    = "../modules/resources/cosmos/mongo"
#   cosmos_mongo_server_name  = "${local.pet}mongo"
#   resource_group_name       = module.resource_group.az_rg_name
#   location                  = module.resource_group.az_rg_location
#   virtual_network_subnet_id = module.cosmos_mongo_sbn.subnet_id

#   cosmos_mongo_tags = local.common_tags

# }

#######################################################
#           AKS CLUSTER
#######################################################
module "acr" {
  source  = "../modules/resources/kubernetes/acr"
  name    = "${local.pet}acrdoit"
  rg_name = module.resource_group.az_rg_name
  region  = var.region
  tags    = local.common_tags
}

module "cluster" {
  source              = "../modules/resources/kubernetes/aks"
  resource_group_name = module.resource_group.az_rg_name
  location            = module.resource_group.az_rg_location
  environment         = local.common_tags.environment
  naming_prefix       = local.name_prefix
  k8s_version         = var.kubernetes_version
  sku_tier            = "Free"
  dns_prefix          = local.dns_prefix

  # ingress_application_gateway_enabled     = true
  # ingress_application_gateway_name        = "${local.name_prefix}-agw"
  # ingress_application_gateway_subnet_cidr = "10.1.2.0/24"
  local_account_disabled            = false
  private_cluster_enabled           = false
  role_based_access_control_enabled = false
  rbac_aad_managed                  = false

  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"
  network_plugin                 = "azure"
  network_policy                 = "azure"

  aks_node = {
    # sku       = "Standard_Dpds_v5"
    sku       = "Standard_D2_v2"
    count     = 1
    subnet_id = module.private_sbn.subnet_id
  }

  client_id     = var.sp_client_id
  client_secret = var.sp_client_secret


  tags = local.common_tags
}

#######################################################
#           NAMESPACE
#######################################################
module "ns_app" {
  source                     = "../modules/resources/kubernetes/namespace"
  k8s_host                   = module.cluster.host
  k8s_client_certificate     = module.cluster.client_certificate
  k8s_client_key             = module.cluster.client_key
  k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
  name_namespace             = "app-test"
}
module "ns_monitoring" {
  source                     = "../modules/resources/kubernetes/namespace"
  k8s_host                   = module.cluster.host
  k8s_client_certificate     = module.cluster.client_certificate
  k8s_client_key             = module.cluster.client_key
  k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
  name_namespace             = "monitoring"
}

#######################################################
#           CLUSTER CONFIG
#######################################################

resource "azurerm_role_assignment" "acr_pull" {
  for_each                         = { "ACR_1" : module.acr.acr_id }
  scope                            = each.value
  role_definition_name             = "AcrPull"
  principal_id                     = var.sp_client_id
  skip_service_principal_aad_check = true
}

# module "nginx" {
#   source                      = "../modules/resources/kubernetes/nginx"
#   k8s_host                    = module.cluster.host
#   k8s_client_certificate      = module.cluster.client_certificate
#   k8s_client_key              = module.cluster.client_key
#   k8s_cluster_ca_certificate  = module.cluster.cluster_ca_certificate
#   kubernetes_namespace        = "ingress-nginx"
#   kubernetes_create_namespace = true
#   enable_default_tls          = true
#   helm_release_name           = "my-release"
#   metrics_enabled             = "true"
# }

# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
# resource "helm_release" "kube-prometheus" {
#   name       = "kube-prometheus-stack"
#   namespace  = module.ns_monitoring.name
#   version    = "39.11.0"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"

#   set {
#     name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
#     value = "false"
#   }
#   set {
#     name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
#     value = "false"
#   }
#   set {
#     name = "prometheus\\.additionalServiceMonitors"
#     value = yamlencode(
#       [
#         {
#           "name" : "ingress-nginx-monitor",
#           "selector" : {
#             "matchLabels" : {
#               "app.kubernetes.io/name" : "nginx-ingress-controller-ingress-nginx-controller-metrics"
#             }
#           },
#           "namespaceSelector" : {
#             "matchNames" : [
#               "ingress-nginx"
#             ]
#           },
#           "endpoints" : [
#             {
#               "port" : "10254"
#               "path" : "metrics"
#             }
#           ]
#         },
#         {
#           "name" : "webapp-monitor",
#           "selector" : {
#             "matchLabels" : {
#               "app.kubernetes.io/name" : "aks-learning-api"
#             }
#           },
#           "namespaceSelector" : {
#             "matchNames" : [
#               "default"
#             ]
#           },
#           "endpoints" : [
#             {
#               "port" : "5001"
#               "path" : "metrics"
#             }
#           ]
#         }
#       ]
#     )
#   }
# }


