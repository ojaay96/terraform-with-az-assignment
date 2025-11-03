# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-jaay"
#     storage_account_name = "ojaaystorageaccount"
#     container_name       = "jaaycontainer"
#     key                  = "terraform.tfstate"
#   }
# }


terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateStorageacct"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
