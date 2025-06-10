resource "azurerm_virtual_network_peering" "example_1_to_example_2" {
  name                      = "peer-example-1-to-2"
  resource_group_name       = azurerm_resource_group.example_1.name
  virtual_network_name      = azurerm_virtual_network.example_1.name
  remote_virtual_network_id = azurerm_virtual_network.example_2.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
}

resource "azurerm_virtual_network_peering" "example_2_to_example_1" {
  name                      = "peer-example-2-to-1"
  resource_group_name       = azurerm_resource_group.example_2.name
  virtual_network_name      = azurerm_virtual_network.example_2.name
  remote_virtual_network_id = azurerm_virtual_network.example_1.id

  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
}
