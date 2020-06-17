provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

terraform {
  backend "azurerm" {
    resource_group_name = "tf-remotestorage-rg"
    storage_account_name = "tfremotestorage001"
    container_name = "tfstate"
    key = "remotestate.terraform.tfstate"
  }
}

variable "prefix" {
  default = "tfvm"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West US 2"
  tags      = {
      Environment = "Terraform"
    }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}