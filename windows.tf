resource "azurerm_public_ip" "windows" {
  name                = "${var.prefix}-winpip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform"
  }
}

resource "azurerm_network_security_group" "windows" {
    name                = "${var.prefix}-winnsg"
    location            = "West US 2"
    resource_group_name = azurerm_resource_group.main.name
    
    security_rule {
        name                       = "rdp"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "winrm-http"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "5985"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "winrm-https"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "5986"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform"
    }
}

resource "azurerm_network_interface" "windows" {
  name                = "${var.prefix}-winnic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "windowsconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.windows.id
  }
}

resource "azurerm_network_interface_security_group_association" "windows" {
    network_interface_id      = azurerm_network_interface.windows.id
    network_security_group_id = azurerm_network_security_group.windows.id
}


resource "azurerm_virtual_machine" "windows" {
  name                  = "${var.prefix}-winvm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.windows.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "winosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "winweb"
    admin_username = "tfadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
  }
  tags = {
    environment = "staging"
  }
  
}