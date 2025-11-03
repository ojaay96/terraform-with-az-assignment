#PROVIDERS
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.51.0"
    }
  }
}


provider "azurerm" {
  subscription_id = "4d2f3d90-3f7a-4f44-bb7f-bee999a3638b"
  features {}
}


#RESOURCE GROUP
resource "azurerm_resource_group" "resource-group" {
  name     = var.resource_group_name
  location = var.location
}

#NSG GROUPS
resource "azurerm_network_security_group" "nsg1" {
  name                = var.nsg
  location            =var.location
  resource_group_name = var.resource_group_name
    security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}


#VIRTUAL NETWORKS
resource "azurerm_virtual_network" "virtual-network" {
  name                = var.virtual_network_1
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
  }
}


#SUBNETS
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_1
  address_prefixes     = ["10.0.1.0/24"]
}


#NSG ASSOCIATIONS
resource "azurerm_subnet_network_security_group_association" "nsg_web" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}


#PUBLIC RESOURCES
resource "azurerm_public_ip" "windows_public_ip" {
  name                = "windows-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}


#NETWORK INTERFACES
resource "azurerm_network_interface" "windows_nic" {
  name                = "windows_VM_nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_public_ip.id
  }
}


#WINDOW-11 VIRTUAL MACHINE
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "windows11-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = "jaay"
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.windows_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-pro"
    version   = "latest"
  }

  computer_name      = "win11vm"
  provision_vm_agent = true

  tags = {
    environment = "Windows11_VM"
  }
}


# OUTPUTS
# output "windows_vm_private_ip" {
#   value = azurerm_network_interface.windows_nic.private_ip_address
# }

output "windows_vm_public_ip" {
  value = azurerm_public_ip.windows_public_ip.ip_address
}
