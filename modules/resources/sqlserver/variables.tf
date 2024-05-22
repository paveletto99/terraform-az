variable "config" {
  description = "(required) configuration variable value from the root module"
  type        = {}
}
variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Microsoft SQL Server. Changing this forces a new resource to be created."
  type        = string
}
variable "location" {
  description = " (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}


variable "admin_username" {
  description = "(Optional) The administrator login name for the new server."
  type        = string
  default     = "missadministrator"
}
variable "admin_password" {
  description = " (Optional) The password associated with the administrator_login user."
  type        = string
  sensitive   = true
  default     = "thisIsAdmin12"
}

variable "server_version" {
  description = "(Required) The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)"
  type        = string
  default     = "12.0"
  validation {
    condition     = can(regex("^(2.0|12.0)$", var.server_version)) == true
    error_message = "`server_version`'s possible values are `2.0` or `12.0`."
  }
}

variable "db_collation" {
  description = "(Optional) Specifies the collation of the database"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "db_license_type" {
  description = "(Optional) Specifies the license type applied to this database. Possible values are LicenseIncluded and BasePrice"
  type        = string
  default     = "BasePrice"

  validation {
    condition     = can(regex("^(BasePrice|LicenseIncluded)$", var.db_license_type)) == true
    error_message = "`db_license_type`'s possible values are `BasePrice` or `LicenseIncluded`."
  }
}

variable "log_analytics_workspace_id" {
  description = "(required) for resource diagnostic settings retrieved from monitoring module"
  type        = string
}




# 🎰🎰🎰🎰🎰🎰


variable "license_type" {
  type        = string
  description = "(Required) What type of license the Managed Instance will use."
  default     = "BasePrice"

  validation {
    condition     = can(regex("^(PriceIncluded|BasePrice)$", var.license_type)) == true
    error_message = "`license_type`'s possible values are `PriceIncluded` or `BasePrice`."
  }
}
variable "sku_name" {
  type        = string
  description = "(Required) Specifies the SKU Name for the SQL Managed Instance."
  default     = "GP_Gen5"

  validation {
    condition     = can(regex("^(GP_Gen4|GP_Gen5|GP_Gen8IM|GP_Gen8IH|BC_Gen4|BC_Gen5|BC_Gen8IM|BC_Gen8IH)$", var.sku_name)) == true
    error_message = "`sku_name`'s possible values are GP_Gen4, GP_Gen5, GP_Gen8IM, GP_Gen8IH, BC_Gen4, BC_Gen5, BC_Gen8IM or BC_Gen8IH."
  }
}

variable "storage_size_in_gb" {
  type        = number
  description = "(Required) Maximum storage space for the SQL Managed instance."
  validation {
    condition     = var.storage_size_in_gb % 32 == 0
    error_message = "This should be a multiple of 32 (GB)"
  }
}



variable "storage_account_type" {
  type        = string
  description = "(Optional) Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created."
  default     = "GRS"
  validation {
    condition     = can(regex("^(GRS|LRS|ZRS)$", var.storage_account_type)) == true
    error_message = "Possible values are GRS, LRS and ZRS. The default value is GRS."
  }
}

