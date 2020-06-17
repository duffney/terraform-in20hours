provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

resource "azurerm_resource_group" "remotestate" {
  name     = "tf-remotestorage-rg"
  location = "West US 2"
  tags      = {
      Environment = "Terraform"
    }
}

resource "azurerm_storage_account" "remotestate" {
  name                     = "tfremotestorage001"
  resource_group_name      = azurerm_resource_group.remotestate.name
  location                 = azurerm_resource_group.remotestate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "remotestate" {
  name = "tfstate"
  storage_account_name = azurerm_storage_account.remotestate.name
  container_access_type = "private"
}