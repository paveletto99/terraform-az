output "cosmos_mongo_id" {
  description = "Id of the Cosmos Mongo instance"
  value       = azurerm_cosmosdb_account.cosmo_mongo.id
}
output "connection_strings" {
  description = "A `list` of connection strings available for this CosmosDB account."
  value       = azurerm_cosmosdb_account.cosmo_mongo.connection_strings
}

