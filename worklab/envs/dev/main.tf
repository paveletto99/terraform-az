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
  # custom_data          = local.debian_init
  custom_data          = base64encode(data.template_file.debian_init_script)
  # ssh_public_key       = file("~/.ssh/id_rsa.pub")
  # os_disk_type         = var.os_disk_type
}

# Automation Account
resource "azurerm_automation_account" "auto" {
  name                = "my-automation-account"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

# Role assignment for Automation identity to manage VMs
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "auto_contributor" {
  principal_id         = azurerm_automation_account.auto.identity.principal_id
  role_definition_name = "Virtual Machine Contributor"
  scope                = data.azurerm_subscription.current.id
}

# Start VM Runbook
resource "azurerm_automation_runbook" "start_vm" {
  name                    = "Start-VMs"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name
  runbook_type            = "PowerShell"
  log_verbose             = true
  log_progress            = true
  publish_content_link {
    uri = "https://raw.githubusercontent.com/paveletto99/terraform-az/master/scripts/start-vm-runbook.ps1"
  }
}

# Stop VM Runbook
resource "azurerm_automation_runbook" "stop_vm" {
  name                    = "Stop-VMs"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name
  runbook_type            = "PowerShell"
  log_verbose             = true
  log_progress            = true
  publish_content_link {
    uri = "https://raw.githubusercontent.com/paveletto99/terraform-az/master/scripts/stop-vm-runbook.ps1"
  }
}


# Schedule to start VMs at 7:00 (UTC)
resource "azurerm_automation_schedule" "start_schedule" {
  name                    = "Start-VMs-Schedule"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name
  frequency               = "Week"
  interval                = 1
  timezone                = "W. Europe Standard Time"
  start_time              = "${local.today}T09:00:00Z"
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

# Schedule to stop VMs at 19:00 (UTC)
resource "azurerm_automation_schedule" "stop_schedule" {
  name                    = "Stop-VMs-Schedule"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name
  frequency               = "Week"
  interval                = 1
  timezone                = "W. Europe Standard Time"
  start_time              = "${local.today}T19:00:00Z"
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
}

# Link the start runbook to the start schedule
resource "azurerm_automation_job_schedule" "start_job" {
  automation_account_name = azurerm_automation_account.auto.name
  resource_group_name     = var.resource_group_name
  runbook_name            = azurerm_automation_runbook.start_vm.name
  schedule_name           = azurerm_automation_schedule.start_schedule.name
  parameters = {
    "ResourceGroupName" = var.resource_group_name
    "VMNames"           = join(",", module.vm.vm_name)
  }
}

# Link the stop runbook to the stop schedule
resource "azurerm_automation_job_schedule" "stop_job" {
  automation_account_name = azurerm_automation_account.auto.name
  resource_group_name     = var.resource_group_name
  runbook_name            = azurerm_automation_runbook.stop_vm.name
  schedule_name           = azurerm_automation_schedule.stop_schedule.name
  parameters = {
    "ResourceGroupName" = var.resource_group_name
    "VMNames"           = join(",", module.vm.vm_name)
  }
}
