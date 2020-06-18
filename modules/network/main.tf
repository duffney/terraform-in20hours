provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

variable "prefix" {
  default = "tf-modules"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.netprefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resourcegroup
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = var.resourcegroup
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}