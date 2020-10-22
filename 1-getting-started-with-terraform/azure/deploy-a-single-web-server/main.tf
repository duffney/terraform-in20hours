provider "azurerm" {
  version = "<= 2.31.1"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "eastus"
}

resource "azurerm_public_ip" "example" {
  name = "example-linux-vm"
  resource_group_name = azurerm_resource_group.example.name
  location = azurerm_resource_group.example.location
  allocation_method = "Static"

  tags = {
    name = "terraform-example"
  }
}

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "exampleconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

data "template_file" "custom-data" {
  template = file("custom_data.sh")
}


resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-linux-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "terraform"
  admin_password      = "Password1234!"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  custom_data = base64encode(data.template_file.custom-data.rendered) 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = {
      Name = "terraform-example"
  }
}

output "public_ip" {
  value = azurerm_public_ip.example-lb.ip_address
}