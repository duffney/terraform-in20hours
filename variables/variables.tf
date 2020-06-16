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