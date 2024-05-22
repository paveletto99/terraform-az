variable "environment" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "name" {
  type        = string
  description = "Name of AKS cluster"
  default     = null
}
variable "naming_prefix" {
  type        = string
  description = "Project Prefix Name"
}
variable "location" { type = string }
variable "dns_prefix" {
  default = null
}
variable "k8s_version" {
  type = string
}
variable "sku_tier" {
  default = "Free"
}
variable "aks_node" {
  type = object({
    sku       = string
    count     = number
    subnet_id = string
  })
  description = "This variable defines the subnets data to be created"
}
variable "client_id" {
  type        = string
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
  default     = ""
  nullable    = false
}

variable "client_secret" {
  type        = string
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  default     = ""
  nullable    = false
}
variable "tags" {
  type = map(string)
}

variable "private_cluster_enabled" {
  type        = bool
  description = "If true cluster API server will be exposed only on internal IP address and available only in cluster vnet."
  default     = false
}

variable "role_based_access_control_enabled" {
  type        = bool
  description = "Enable Role Based Access Control."
  default     = false
  nullable    = false
}

variable "ingress_application_gateway_enabled" {
  type        = bool
  description = "Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster?"
  default     = false
  nullable    = false
}

variable "ingress_application_gateway_id" {
  type        = string
  description = "The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster."
  default     = null
}

variable "ingress_application_gateway_name" {
  type        = string
  description = "The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  default     = null
}

variable "ingress_application_gateway_subnet_cidr" {
  type        = string
  description = "The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  default     = null
}

variable "ingress_application_gateway_subnet_id" {
  type        = string
  description = "The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  default     = null
}

variable "net_profile_dns_service_ip" {
  type        = string
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  default     = null
}

variable "net_profile_docker_bridge_cidr" {
  type        = string
  description = "(Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  default     = null
}

variable "net_profile_outbound_type" {
  type        = string
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  type        = string
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
  default     = null
}

variable "net_profile_service_cidr" {
  type        = string
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  default     = null
}

variable "network_plugin" {
  type        = string
  description = "Network plugin to use for networking."
  default     = "kubenet"
  nullable    = false
}

variable "network_policy" {
  type        = string
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
  default     = null
}

variable "local_account_disabled" {
  type        = bool
  description = "(Optional) - If `true` local accounts will be disabled. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts) for more information."
  default     = null
}

variable "rbac_aad_client_app_id" {
  type        = string
  description = "The Client ID of an Azure Active Directory Application."
  default     = null
}
variable "rbac_aad_managed" {
  type        = bool
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  default     = false
  nullable    = false
}

variable "rbac_aad_server_app_id" {
  type        = string
  description = "The Server ID of an Azure Active Directory Application."
  default     = null
}

variable "rbac_aad_server_app_secret" {
  type        = string
  description = "The Server Secret of an Azure Active Directory Application."
  default     = null
}

variable "rbac_aad_tenant_id" {
  type        = string
  description = "(Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
  default     = null
}

variable "rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "Object ID of groups with admin access."
  default     = null
}

variable "rbac_aad_azure_rbac_enabled" {
  type        = bool
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  default     = null
}

variable "identity_ids" {
  type        = list(string)
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster."
  default     = null
}

variable "identity_type" {
  type        = string
  description = "(Optional) The type of identity used for the managed cluster. Conflict with `client_id` and `client_secret`. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`(to enable both). If `UserAssigned` or `SystemAssigned, UserAssigned` is set, an `identity_ids` must be set as well."
  default     = "SystemAssigned"

  validation {
    condition     = var.identity_type == "SystemAssigned" || var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned"
    error_message = "`identity_type`'s possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`(to enable both)."
  }
}


