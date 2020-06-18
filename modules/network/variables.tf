variable "resourcegroup" {
    type = string
    description = "azure resource group"
}

variable "location" {
  type = string
  description = "azure region"
  default = "West US 2"
}

variable "netprefix" {
  type = string
}