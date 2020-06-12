variable "prefix" {
  default = "interpolation"
}

resource "azurerm_resource_group" "interpolation" {
  name     = "${var.prefix}-resources"
  location = "West US 2"
  tags      = {
      Environment = "Terraform"
    }
}

resource "azurerm_virtual_network" "interpolation" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.interpolation.location
  resource_group_name = azurerm_resource_group.interpolation.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.interpolation.name
  virtual_network_name = azurerm_virtual_network.interpolation.name
  address_prefixes     = ["10.0.2.0/24"]
}