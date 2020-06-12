locals {
  prefix = "depends"
  location = "West US 2"
}

resource "azurerm_resource_group" "depends" {
  name     = "${local.prefix}-resources"
  location = local.location
  tags      = {
      Environment = "Terraform"
    }
}

resource "azurerm_virtual_network" "depends" {
  name                = "${local.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = "${local.prefix}-resources"
  
  depends_on = [
    azurerm_resource_group.depends,
  ]
}

resource "azurerm_subnet" "depends" {
  name                 = "internal"
  resource_group_name  = "${local.prefix}-resources"
  virtual_network_name = "${local.prefix}-network"
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [
    azurerm_resource_group.depends,
    azurerm_virtual_network.depends,
  ]
}