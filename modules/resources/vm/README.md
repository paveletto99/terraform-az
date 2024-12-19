# VM Module

This module creates a Linux virtual machine in Azure.

## Inputs

- `vm_name`: The name of the virtual machine.
- `resource_group_name`: The name of the resource group.
- `location`: The Azure region.
- `vm_size`: The size of the virtual machine (default: `Standard_D16ps_v5`).
- `admin_username`: The admin username for the virtual machine.
- `ssh_public_key`: The SSH public key for accessing the VM.
- `os_disk_type`: The type of the OS disk (default: `StandardSSD_LRS`).
- `os_disk_size`: The size of the OS disk in GB (default: `128`).
- `network_interface_id`: The ID of the network interface to attach to the VM.
- `image_publisher`, `image_offer`, `image_sku`: Details of the OS image.
- `custom_data`: Cloud-init or other boot configuration scripts.

## Outputs

- `vm_id`: The ID of the created virtual machine.
- `vm_name`: The name of the created virtual machine.
- `private_ip_address`: The private IP of the VM.
