resource "random_integer" "rand" {
  min = 10000
  max = 99999
}
resource "random_pet" "rn" {
  length = 1
}


data "template_file" "debian_init_script" {
  template = file("../../../scripts/debian-init")
}

locals {
  common_tags = {
    company     = var.company
    project     = "${var.company}-${var.project}"
    environment = terraform.workspace
  }

  pet = random_pet.rn.id

  name_prefix = "${var.naming_prefix}-${local.common_tags.environment}-${random_pet.rn.id}"
  dns_prefix  = "aks${random_pet.rn.id}"

  today = formatdate("YYYY-MM-DD", timestamp())

  debian_init = base64encode(<<EOT
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
}

