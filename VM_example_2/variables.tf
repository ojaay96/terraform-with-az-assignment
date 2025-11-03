variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "east us"
  description = "Azure region where resources will be deployed"
}

variable "nsg" {
  type = string
  description = "This is the nsg"
}

variable "virtual_network_1" {
  type        = string
  default = "vnet-production"
  description = "This is the name for Virtual Network"
}

variable "subnet" {
  type        = string
  description = "This is the Subnet"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password for the Windows VM"
}
