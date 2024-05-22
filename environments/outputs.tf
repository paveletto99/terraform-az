# output "az_tf_training" {
#   value = azurerm_resource_group.rg
# }

# output "resource_group_details" {
#   value = module.remoteStateRg
# }


# output "storage_account_details" {
#   value     = azurerm_storage_account.storage_account
#   sensitive = true
# }

# output "storage_account_ids" {
#   value = azurerm_storage_account.storage_account.id
# }

# output "sas_container_query_string" {
#   value     = data.azurerm_storage_account_blob_container_sas.container-sas.sas
#   sensitive = true
# }
# output "sas_storage_query_string" {
#   value     = data.azurerm_storage_account_sas.storage-sas.sas
#   sensitive = true
# }

output "resource_group_name" {
  value = module.resource_group.az_rg_name
}


# K8S
output "kubernetes_cluster_name" {
  value     = module.cluster.name
  sensitive = true
}
resource "local_file" "kubeconfig" {
  depends_on = [module.cluster]
  filename   = "kubeconfig"
  content    = module.cluster.kube_config
}

output "kubeconfig" {
  value     = module.cluster.kube_config
  sensitive = true
}

# output "cluster_pip" {
#   value = azurerm_public_ip.nginx_ingress_pip.ip_address
# }

# MONITORING
# output "grafana_pwd" {
#   value     = random_password.grafana.result
#   sensitive = true
# }


