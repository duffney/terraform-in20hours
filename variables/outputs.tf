output "pip" {
    description = "Public IP Address of Virtual Machine"
    value = azurerm_public_ip.linux.ip_address
    #TODO: add depends_on for vm object, results in null on first pass
}

