resource "random_integer" "rand" {
  min = 10000
  max = 99999
}
resource "random_pet" "rn" {
  length = 1
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
}
