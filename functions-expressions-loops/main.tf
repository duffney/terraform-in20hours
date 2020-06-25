# create app gateway with piip and 3 machines behind it

provider "azurerm" {
  features{}
  version = "2.9.0"
  #subscription_id = ""
}

resource "azurerm_resource_group" "main" {
  name     = lower("${var.prefix}-resources") 
  location = "West US 2"
  tags = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = var.address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = lower("${var.prefix}-subnet")
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_public_ip" "lb" {
  name                = lower("${var.prefix}-lb-pip") 
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = lower("${var.prefix}-lb")
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "tf-web"
}

resource "azurerm_lb_probe" "lb" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "http-running-probe"
  port                = 80
}

resource "azurerm_lb_rule" "lb" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
  probe_id = azurerm_lb_probe.lb.id
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-aset"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = var.tags
}


resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip--${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  tags = var.tags
  count = 3
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-config-${count.index}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.main.*.id, count.index)}"
  }

  count = 3
}

resource "azurerm_network_interface_backend_address_pool_association" "lb" {
  network_interface_id    = "${element(azurerm_network_interface.main.*.id, count.index)}"
  ip_configuration_name   = "${var.prefix}-config-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
  count = 3
}


resource "azurerm_virtual_machine" "main" {

  count = 3

  name                  = "${var.prefix}-vm-${count.index}"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  vm_size               = lookup(var.vmsize, var.env)
  availability_set_id = azurerm_availability_set.main.id

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.os.publisher
    offer     = var.os.offer
    sku       = var.os.sku
    version   = var.os.version
  }
  storage_os_disk {
    name              = "linwebdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "linweb-${count.index}"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tags
}