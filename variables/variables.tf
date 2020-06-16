variable "prefix" {
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
}

variable "vmsize" {
  type = map
  default = {
    dev = "Standard_DS1_v2"
    prod = "Standard_D2_v2"
  }
}