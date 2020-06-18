provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

terraform {
  backend "remote" {
    organization = "duffneyio"

    workspaces {
      name = "terraform-in20hours"
    }
  }
}

variable "prefix" {
  default = "tf-cloud"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West US 2"
  tags      = {
      Environment = "Terraform Cloud"
    }
}