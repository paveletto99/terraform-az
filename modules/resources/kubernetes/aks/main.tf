# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster

resource "azurerm_kubernetes_cluster" "aks" {
  location                          = var.location
  name                              = var.name == null ? "${var.naming_prefix}-${var.environment}-${var.location}-aks" : var.name
  dns_prefix                        = var.dns_prefix == null ? "${var.naming_prefix}${var.environment}${var.location}" : var.dns_prefix
  resource_group_name               = var.resource_group_name
  kubernetes_version                = var.k8s_version
  sku_tier                          = var.sku_tier
  node_resource_group               = "AG_${var.resource_group_name}"
  local_account_disabled            = var.local_account_disabled
  http_application_routing_enabled  = true
  role_based_access_control_enabled = var.role_based_access_control_enabled
  private_cluster_enabled           = var.private_cluster_enabled

  tags = var.tags

  default_node_pool {
    name            = "sys${var.environment}"
    vm_size         = var.aks_node.sku
    node_count      = var.aks_node.count
    zones           = ["1", "2"]
    os_disk_size_gb = 64
    vnet_subnet_id  = var.aks_node.subnet_id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin     = var.network_plugin
    dns_service_ip     = var.net_profile_dns_service_ip
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    network_policy     = var.network_policy
    outbound_type      = var.net_profile_outbound_type
    pod_cidr           = var.net_profile_pod_cidr
    service_cidr       = var.net_profile_service_cidr
  }
  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway_enabled ? ["ingress_application_gateway"] : []

    content {
      gateway_id   = var.ingress_application_gateway_id
      gateway_name = var.ingress_application_gateway_name
      subnet_cidr  = var.ingress_application_gateway_subnet_cidr
      subnet_id    = var.ingress_application_gateway_subnet_id
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled && var.rbac_aad_managed ? ["rbac"] : []

    content {
      admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      azure_rbac_enabled     = var.rbac_aad_azure_rbac_enabled
      managed                = true
      tenant_id              = var.rbac_aad_tenant_id
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled && !var.rbac_aad_managed ? ["rbac"] : []

    content {
      client_app_id     = var.rbac_aad_client_app_id
      managed           = false
      server_app_id     = var.rbac_aad_server_app_id
      server_app_secret = var.rbac_aad_server_app_secret
      tenant_id         = var.rbac_aad_tenant_id
    }
  }

  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }


  lifecycle {
    precondition {
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type != "")
      error_message = "Either `client_id` and `client_secret` or `identity_type` must be set."
    }
    precondition {
      # Why don't use var.identity_ids != null && length(var.identity_ids)>0 ? Because bool expression in Terraform is not short circuit so even var.identity_ids is null Terraform will still invoke length function with null and cause error. https://github.com/hashicorp/terraform/issues/24128
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type == "SystemAssigned") || (var.identity_ids == null ? false : length(var.identity_ids) > 0)
      error_message = "If use identity and `UserAssigned` or `SystemAssigned, UserAssigned` is set, an `identity_ids` must be set as well."
    }
  }

}
