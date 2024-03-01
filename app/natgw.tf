# resource "azurerm_public_ip" "pmxapp_natip" {
#   name                = "nat-gateway-publicIP"
#   resource_group_name = azurerm_resource_group.pmxapp_rg.name
#   location            = azurerm_resource_group.pmxapp_rg.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   zones               = ["1"]
# }

# resource "azurerm_nat_gateway" "pmxapp_natgw" {
#   name                    = "nat-Gateway"
#   resource_group_name     = azurerm_resource_group.pmxapp_rg.name
#   location                = azurerm_resource_group.pmxapp_rg.location
#   sku_name                = "Standard"
#   idle_timeout_in_minutes = 10
#   zones                   = ["1"]
# }

# resource "azurerm_nat_gateway_public_ip_association" "pmxapp_natipasc" {
#   nat_gateway_id       = azurerm_nat_gateway.pmxapp_natgw.id
#   public_ip_address_id = azurerm_public_ip.pmxapp_natip.id
# }

# resource "azurerm_subnet_nat_gateway_association" "pmxapp_natsubasc" {
#   subnet_id      = azurerm_subnet.pmxapp_subnet.id
#   nat_gateway_id = azurerm_nat_gateway.pmxapp_natgw.id
# }