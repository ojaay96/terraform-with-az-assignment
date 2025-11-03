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
    resource_group_name  = "rg-jaay-terraform"
    storage_account_name = "jaaytfstorageacct"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
