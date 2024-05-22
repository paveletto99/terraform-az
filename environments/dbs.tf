#######################################################
#           STORAGE
#######################################################

# resource "azurerm_storage_account" "storage_account" {
#   name                      = "${var.storage_account_name}${random_integer.rand.result}"
#   resource_group_name       = module.resource_group.resource_groupName
#   location                  = module.resource_group.resource_groupLocation
#   account_tier              = "Standard"
#   account_replication_type  = "LRS"
#   account_kind              = "StorageV2"
#   min_tls_version           = "TLS1_2"
#   enable_https_traffic_only = true
#   tags                      = local.common_tags
# }

#######################################################
#           REMOTE STATE
#######################################################

# module "remoteStateRg" {
#   source                = "./modules/resources/groups"
#   resource_groupName     = "${local.name_prefix}-rg-state"
#   resource_groupLocation = var.region
#   resource_groupTags     = local.common_tags
# }

# resource "azurerm_storage_account" "remotestatestorage" {
#   name                      = "remotestatestorage${random_integer.rand.result}"
#   resource_group_name       = module.remoteStateRg.resource_groupName
#   location                  = module.remoteStateRg.resource_groupLocation
#   account_tier              = "Standard"
#   account_replication_type  = "GRS"
#   enable_https_traffic_only = true
#   allow_blob_public_access  = false
#   min_tls_version           = "TLS1_2"
#   tags                      = local.common_tags
# }

# resource "azurerm_storage_container" "remotestate-container" {
#   name                  = "statefiles"
#   storage_account_name  = azurerm_storage_account.remotestatestorage.name
#   container_access_type = "private"
# }

# The next set of code listings will generate a token that can be used for accessing the content of the storage account.
# The first one will provide access to only the blob service.
# The token will be valid within the shown start and expiry dates.
# The content can be accessed only using the TLS protocol,
# and it would have read, write, delete, list, add, create, update and process permissions.

# data "azurerm_storage_account_sas" "storage-sas" {
#   connection_string = azurerm_storage_account.remotestatestorage.primary_connection_string
#   https_only        = true
#   start             = current_time
#   expiry            = timeadd(current_time, expiry_deadline)
#   services {
#     blob  = true
#     queue = false
#     table = false
#     file  = false
#   }
#   resource_types {
#     service   = true
#     container = true
#     object    = true
#   }
#   permissions {
#     read    = true
#     write   = true
#     delete  = true
#     list    = true
#     add     = true
#     create  = true
#     update  = true
#     process = true
#     tag     = false
#     filter  = false
#   }
# }

# The next code listing can provide access only to a blob container within a storage account
# data "azurerm_storage_account_blob_container_sas" "container-sas" {
#   connection_string = azurerm_storage_account.remotestatestorage.primary_connection_string
#   container_name    = azurerm_storage_container.remotestate-container.name
#   https_only        = true
#   start             = current_time
#   expiry            = timeadd(current_time, expiry_deadline)
#   permissions {
#     read   = true
#     add    = true
#     create = true
#     write  = true
#     delete = true
#     list   = true
#   }
#   cache_control       = "max-age=5"
#   content_disposition = "inline"
#   content_encoding    = "deflate"
#   content_language    = "en-US"
#   content_type        = "application/json"
# }