provider "azurerm" {
  version = "<= 2.31.1"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "eastus"
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

resource "azurerm_public_ip" "example-lb" {
  name                = "lb-pip"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "web-lb"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                          = "lb-ip-config"
    public_ip_address_id          = azurerm_public_ip.example-lb.id
  }
}

resource "azurerm_lb_probe" "example" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "http-running"
  port                = 8080
}

resource "azurerm_lb_backend_address_pool" "example" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "PublicIPAddress"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.example.id
  ip_configuration_name   = "PublicIPAddress"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "http"
  protocol            = "Http"
  port                = 8080
  request_path        = "/"
}

resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "httprule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.example.id
  probe_id                       = azurerm_lb_probe.http.id
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

output "lb_public_ip" {
    value = azurerm_public_ip.example-lb.ip_address
}