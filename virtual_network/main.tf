#PROVIDERS
terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.29.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "4d2f3d90-3f7a-4f44-bb7f-bee999a3638b"
  features {}
}


#RESOURCE GROUPS
resource "azurerm_resource_group" "example_1" {
  name     = "example_1_resources"
  location = "West Europe"
}

resource "azurerm_resource_group" "example_2" {
  name     = "example_2_resources"
  location = "West Europe"
}

#NSG GROUPS
resource "azurerm_network_security_group" "example_1" {
  name                = "example_1_security_group"
  location            = azurerm_resource_group.example_1.location
  resource_group_name = azurerm_resource_group.example_1.name
}

resource "azurerm_network_security_group" "example_2" {
  name                = "example_2_security_group"
  location            = azurerm_resource_group.example_2.location
  resource_group_name = azurerm_resource_group.example_2.name
}

#VIRTUAL NETWORKS
resource "azurerm_virtual_network" "example_1" {
  name                = var.virtual_network_name1
  location            = azurerm_resource_group.example_1.location
  resource_group_name = azurerm_resource_group.example_1.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "example_2" {
  name                = var.virtual_network_name2
  location            = azurerm_resource_group.example_2.location
  resource_group_name = azurerm_resource_group.example_2.name
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Deployment"
  }
}

#SUBNETS
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.example_1.name
  virtual_network_name = azurerm_virtual_network.example_1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.example_2.name
  virtual_network_name = azurerm_virtual_network.example_2.name
  address_prefixes     = ["10.1.2.0/24"]
}

#NSG ASSOCIATIONS
resource "azurerm_subnet_network_security_group_association" "example_1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.example_1.id
}

resource "azurerm_subnet_network_security_group_association" "example_2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.example_2.id
}

#PUBLIC RESOURCES
resource "azurerm_public_ip" "windows_public_ip" {
  name                = "windows-public-ip"
  location            = azurerm_resource_group.example_1.location
  resource_group_name = azurerm_resource_group.example_1.name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "linux_public_ip" {
  name                = "linux-public-ip"
  location            = azurerm_resource_group.example_2.location
  resource_group_name = azurerm_resource_group.example_2.name
  allocation_method   = "Dynamic"
  sku                 = "Standard"
}

#NETWORK INTERFACES
resource "azurerm_network_interface" "windows_nic" {
  name                = "windows-nic"
  location            = azurerm_resource_group.example_1.location
  resource_group_name = azurerm_resource_group.example_1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_public_ip.id
  }
}

resource "azurerm_network_interface" "linux_nic" {
  name                = "linux-nic"
  location            = azurerm_resource_group.example_2.location
  resource_group_name = azurerm_resource_group.example_2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_public_ip.id
  }
}

#WINDOW-11 VIRTUAL MACHINE
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "windows11-vm"
  resource_group_name = azurerm_resource_group.example_1.name
  location            = azurerm_resource_group.example_1.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"

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

# LINUX VM
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "linux-vm"
  resource_group_name = azurerm_resource_group.example_2.name
  location            = azurerm_resource_group.example_2.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "ChangeMe123!" 

  network_interface_ids = [
    azurerm_network_interface.linux_nic.id,
  ]

  disable_password_authentication = false

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("C:/Users/hp/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name      = "linuxvm"
  provision_vm_agent = true

  tags = {
    environment = "LinuxVM"
  }
}

# OUTPUTS
output "windows_vm_private_ip" {
  value = azurerm_network_interface.windows_nic.private_ip_address
}

output "linux_vm_private_ip" {
  value = azurerm_network_interface.linux_nic.private_ip_address
}

output "windows_vm_public_ip" {
  value = azurerm_public_ip.windows_public_ip.ip_address
}

output "linux_vm_public_ip" {
  value = azurerm_public_ip.linux_public_ip.ip_address
}

