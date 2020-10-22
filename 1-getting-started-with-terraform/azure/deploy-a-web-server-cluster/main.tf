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
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "example-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard_DS1_v2"
  instances           = 2
  admin_username      = "terraform"
  admin_password      = "Password1234!"
  custom_data         = base64encode("echo 'terraform-in20hours' > index.html && nohup busybox httpd -f -p 8080 &")
  disable_password_authentication = "false"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]
    }
  }
}

resource "azurerm_public_ip" "example" {
  name                = "lb-pip"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "vmss_lb"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "example" {
 resource_group_name = azurerm_resource_group.example.name
 loadbalancer_id     = azurerm_lb.example.id
 name                = "http-up-probe"
 port                = 8080 
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = azurerm_resource_group.example.name
   loadbalancer_id                = azurerm_lb.example.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = 8080
   backend_port                   = 8080 
   backend_address_pool_id        = azurerm_lb_backend_address_pool.example.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.example.id
}

resource "azurerm_lb_nat_pool" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
}