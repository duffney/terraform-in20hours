variable "vmpassword" {
    type = string
    description = "Administrator password for server"
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