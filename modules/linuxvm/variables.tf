variable "resourcegroup" {
    type = string
    description = "azure resource group"
}

variable "location" {
  type = string
  description = "azure region"
  default = "West US 2"
}


variable "vmprefix" {
  default = "tfvm"
}

variable "username" {
    type = string
    description = "Administrator username for server"
    default = "tfadmin"
}

variable "password" {
    type = string
    description = "Administrator password for server"
}

variable "env" {
  type = string
  description = "type of environment"
  default = "dev"
}

variable "vmsize" {
  type = map
  default = {
    dev = "Standard_DS1_v2"
    prod = "Standard_D2_v2"
  }
}

variable "vmos" {
    description = "OS image to deploy"
    type = object({
        publisher = string
        offer = string
        sku = string
        version = string
  })
}

variable "subnetid" {
  type = string
  description = "(optional) describe your variable"
}