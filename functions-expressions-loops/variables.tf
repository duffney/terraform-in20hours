variable "prefix" {
  type = string
  default = "tf-ag"
}

variable "computer_name" {
  type = string
  default = "nixweb"
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

variable "address_space" {
  type = list
}

variable "address_prefixes" {
  type = list
}

variable "tags" {
    type = map

    default = {
        environment = "Terraform"
        owner = "Josh Duffney"
  }
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

variable "os" {
    description = "OS image to deploy"
    type = object({
        publisher = string
        offer = string
        sku = string
        version = string
  })
}