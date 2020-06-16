resource "azurerm_public_ip" "linux" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  #NOTE: Had to switch to static because dynamic isn't allocated until attached to a vm and caused provisoner to fail as it didn't have a IP.
  allocation_method   = "Static"

  tags = {
    environment = "Terraform"
  }
}

resource "azurerm_network_security_group" "linux" {
    name                = "${var.prefix}-nsg"
    location            = "West US 2"
    resource_group_name = azurerm_resource_group.main.name
    
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
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "linuxconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.linux.id
  }
}

resource "azurerm_network_interface_security_group_association" "linux" {
    network_interface_id      = azurerm_network_interface.linux.id
    network_security_group_id = azurerm_network_security_group.linux.id
}

resource "azurerm_virtual_machine" "linux" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.linux.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "linuxweb"
    admin_username = "tfadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  provisioner "local-exec" {
    command = "echo 'local provisioner worked'"
  }


  #TODO: try changing ip to static instead of dynamic
  provisioner "remote-exec" {
    inline = [
      "echo 'remote provisioner worked'"
    ]
    connection {
      type     = "ssh"
      user     = "tfadmin"
      password = "Password1234!"
      host     =  azurerm_public_ip.linux.ip_address
    }
  }
}

# data "azurerm_public_ip" "linux" {
#   name                = azurerm_public_ip.linux.name
#   resource_group_name = azurerm_resource_group.main.name
# }

# output "public_ip_address" {
#   value = data.azurerm_public_ip.linux.ip_address
# }