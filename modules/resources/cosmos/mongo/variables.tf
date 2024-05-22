
variable "resource_group_name" {
  type        = string
  description = "Name of resource group for hosting sql server and database"
}
variable "location" {
  type        = string
  description = "Azure region for resource group and sql resources"
}
variable "cosmos_mongo_server_name" {
  type        = string
  description = "Specifies the name of the CosmosDB Account."
}

variable "cosmos_mongo_tags" {
  type        = map(string)
  description = "value"
}

variable "kind" {
  description = "Specifies the Kind of CosmosDB to create"
  type        = string
  default     = "MongoDB"

  validation {
    condition     = can(regex("^(MongoDB|GlobalDocumentDB)$", var.kind)) == true
    error_message = "`kind`'s possible values are `MongoDB` or `GlobalDocumentDB`."
  }
}

variable "enable_systemassigned_identity" {
  type        = bool
  description = "Enable System Assigned Identity"
  default     = false
}

variable "geo_locations" {
  description = "List of map of geo locations and other properties to create primary and secodanry databasees."
  type        = any
  default = [
    {
      geo_location      = "westeurope"
      failover_priority = 0
      zone_redundant    = false
    },
  ]
}


variable "consistency_level" {
  description = "The Consistency Level to use for this CosmosDB Account."
  type        = string
  default     = "BoundedStaleness"

  validation {
    condition     = can(regex("^(BoundedStaleness|Eventual|Session|Strong|ConsistentPrefix)$", var.consistency_level)) == true
    error_message = "`consistency_level`'s possible values can be either `BoundedStaleness`, `Eventual`, `Session`, `Strong` or `ConsistentPrefix`."
  }

}

variable "virtual_network_subnet_id" {
  description = "The ID of the virtual network subnet."
  type        = string
}

/* Mongo API Variables*/
variable "mongo_dbs" {
  type = map(object({
    db_name           = string
    db_throughput     = number
    db_max_throughput = number
  }))
  description = "Map of Cosmos DB Mongo DBs to create. Some parameters are inherited from cosmos account."
  default     = {}
}

