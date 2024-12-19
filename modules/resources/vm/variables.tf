variable "vm_name" {
  description = "The name of the VM"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the VM will be created"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_D16ps_v5"
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}
# variable "ssh_public_key" {
#   description = "The SSH public key for the admin user"
#   type        = string
# }

variable "os_disk_type" {
  description = "The storage type for the OS disk"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_disk_size" {
  description = "The size of the OS disk in GB"
  type        = number
  default     = 128
}

variable "network_interface_id" {
  description = "The ID of the network interface to attach to the VM"
  type        = string
}

variable "image_publisher" {
  description = "The publisher of the image"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "The offer of the image"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "The SKU of the image"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "custom_data" {
  description = "Custom data to configure the VM at boot time"
  type        = string
  default     = ""
}
