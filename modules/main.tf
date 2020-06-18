provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

variable "prefix" {
  default = "tf-modules"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = "West US 2"
  tags      = {
      Environment = "Terraform"
    }
}

module "network" {
  source = "./network"
  netprefix = var.prefix
  resourcegroup = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
}

module "linuxvm" {
  source = "./linuxvm"
  vmprefix = var.prefix
  resourcegroup = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  vmos = var.os
  password = var.vmpassword
  subnetid = module.network.subnetid
}