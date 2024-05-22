# ------------------------------ Manages a Microsoft SQL Azure Database Server. ------------------------------ #
resource "azurerm_mssql_server" "this" {
  name                = "tms-mmsql-srv${var.config.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  version = var.server_version

  minimum_tls_version = "1.2"
  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = false

  # FIXME ?? az admin needed ??
  # identity
  # primary_user_assigned_identity_id
  # azuread_administrator {
  #   login_username = "AzureAD Admin"
  #   object_id      = "00000000-0000-0000-0000-000000000000"
  # }

  tags = merge(var.config.tags, { Purpose = "Manages a Microsoft SQL Azure Database Server." })

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Manages a MS SQL Database.
resource "azurerm_mssql_database" "this" {
  name = "tms-mmsql-db${var.config.suffix}"

  server_id      = var.server_id
  collation      = var.db_collation
  license_type   = var.db_license_type
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S2" // deafult S2
  zone_redundant = false

  tags = merge(var.config.tags, { Purpose = "Manages a Microsoft SQL Azure Database Server." })

}

resource "azurerm_private_endpoint" "this" {
  count               = var.config.networking.enable_pve ? 1 : 0
  name                = "tms-mmsql-pve${var.config.suffix}"
  location            = var.resource_group_platform.location
  resource_group_name = var.resource_group_platform.name
  subnet_id           = var.pve_subnet_id

  tags = merge(var.config.tags, { Purpose = "Private endpoint resource for Microsoft SQL Azure Database Server." })

  private_dns_zone_group {
    name                 = "tms"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  private_service_connection {
    name                           = "${var.name}privateserviceconnection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
  }
}


resource "azurerm_monitor_diagnostic_setting" "this" {
  count                          = var.config.monitoring.enable_diagnostic_setting ? 1 : 0
  name                           = "tms-msdk-msdk"
  target_resource_id             = azurerm_mssql_server.this
  log_analytics_destination_type = "AzureDiagnostics"
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"

    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
