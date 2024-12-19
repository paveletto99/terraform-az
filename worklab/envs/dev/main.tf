#######################################################
#           GROUPS
#######################################################
module "resource_group" {
  source   = "../../../modules/resources/groups"
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

#######################################################
#           NETWORK
#######################################################
module "vnet" {
  source             = "../../../modules/resources/network/vnet"
  region             = var.location
  vnet_name          = "${local.name_prefix}-vnet"
  vnet_rg_name       = module.resource_group.az_rg_name
  vnet_address_space = ["10.1.0.0/16"]

  vnet_resource_tags = local.common_tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = module.vnet.az_vnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
#######################################################
#           VM
#######################################################
module "vm" {
  source               = "../../../modules/resources/vm"
  vm_name              = var.vm_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_password       = "SecurePassword123!"
  network_interface_id = module.vnet.az_vnet.id
  os_disk_size         = 128
  custom_data = base64encode(<<EOT
#!/bin/bash
apt update -y
apt upgrade -y
apt install -y ubuntu-desktop
systemctl set-default graphical.target
# rdp
apt install -y xrdp
systemctl enable xrdp
systemctl start xrdp
ufw allow 3389
EOT
  )
  # ssh_public_key       = file("~/.ssh/id_rsa.pub")
  # os_disk_type         = var.os_disk_type
}
