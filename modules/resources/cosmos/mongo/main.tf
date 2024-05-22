##########################################################
#   CosmosDB (formally DocumentDB)           #############
##########################################################

resource "azurerm_cosmosdb_account" "cosmo_mongo" {
  name                = var.cosmos_mongo_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  offer_type           = "Standard"
  kind                 = var.kind
  mongo_server_version = "4.2"
  enable_free_tier     = true

  tags = var.cosmos_mongo_tags


  virtual_network_rule {
    id = var.virtual_network_subnet_id
    # ignore_missing_vnet_service_endpoint = true
  }
  is_virtual_network_filter_enabled = true
  public_network_access_enabled     = false

  dynamic "identity" {
    for_each = var.enable_systemassigned_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  capacity {
    total_throughput_limit = -1
  }

  # default_identity_type = "" TODO to add

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    # TODO check the correct consistency https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/consistency-mapping
    consistency_level       = var.consistency_level
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  dynamic "geo_location" {
    for_each = var.geo_locations
    content {
      location          = geo_location.value["geo_location"]
      failover_priority = geo_location.value["failover_priority"]
      zone_redundant    = geo_location.value["zone_redundant"]
    }
  }

  lifecycle {
    ignore_changes = [
      tags, # additional resource tags are managed and enforced by an external entity
    ]
  }
}

resource "azurerm_cosmosdb_mongo_database" "this" {
  for_each            = var.mongo_dbs
  name                = each.value.db_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmo_mongo.name
  throughput          = each.value.db_max_throughput != null ? null : each.value.db_throughput

  # Autoscaling is optional and depends on max throughput parameter. Mutually exclusive vs. throughput. 
  dynamic "autoscale_settings" {
    for_each = each.value.db_max_throughput != null ? [1] : []
    content {
      max_throughput = each.value.db_max_throughput
    }
  }
}
