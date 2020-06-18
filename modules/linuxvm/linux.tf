resource "azurerm_public_ip" "linux" {
  name                = "${var.vmprefix}-pip"
  resource_group_name = var.resourcegroup
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform"
  }
}

resource "azurerm_network_security_group" "linux" {
    name                = "${var.vmprefix}-nsg"
    location            = "West US 2"
    resource_group_name = var.resourcegroup
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform"
    }
}

resource "azurerm_network_interface" "linux" {
  name                = "${var.vmprefix}-nic"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "linuxconfig"
    subnet_id                     = var.subnetid
    #azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.linux.id
  }
}

resource "azurerm_network_interface_security_group_association" "linux" {
    network_interface_id      = azurerm_network_interface.linux.id
    network_security_group_id = azurerm_network_security_group.linux.id
}

resource "azurerm_virtual_machine" "linux" {
  name                  = "${var.vmprefix}-vm"
  location              = var.location
  resource_group_name   = var.resourcegroup
  network_interface_ids = [azurerm_network_interface.linux.id]
  vm_size               = lookup(var.vmsize, var.env)

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.vmos.publisher
    offer     = var.vmos.offer
    sku       = var.vmos.sku
    version   = var.vmos.version
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "linuxweb"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}