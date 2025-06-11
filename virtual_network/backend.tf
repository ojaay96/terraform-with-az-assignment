terraform {
  backend "azurerm" {
    resource_group_name  = "rg-jaay"
    storage_account_name = "ojaaystorageaccount"
    container_name       = "jaaycontainer"
    key                  = "terraform.tfstate" 
  }
}
