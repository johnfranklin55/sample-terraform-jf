resource "azurerm_private_dns_zone" "pmxlocal_dnszone" {
  count               = var.pmxservices == true ? 1 : 0
  name                = "pmxlocal.com"
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
}

data "azurerm_virtual_network" "services_network" {
  count               = var.pmxservices == true ? 1 : 0
  name                = "vnet-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-services"
  resource_group_name = "rg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-services"
}

resource "azurerm_private_dns_zone_virtual_network_link" "pmxlocal_dns_AppNetwork_link" {
  count                 = var.pmxservices == true ? 1 : 0
  name                  = "pmxApp_vnet_link"
  resource_group_name   = azurerm_resource_group.pmxapp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pmxlocal_dnszone[count.index].name
  virtual_network_id    = azurerm_virtual_network.pmxapp_vnet.id
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "pmxlocal_dns_ServicesNetwork_link" {
  count                 = var.pmxservices == true ? 1 : 0
  name                  = "pmxServices_vnet_link"
  resource_group_name   = azurerm_resource_group.pmxapp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pmxlocal_dnszone[count.index].name
  virtual_network_id    = data.azurerm_virtual_network.services_network[count.index].id
}

resource "azurerm_private_dns_a_record" "scw_a_record_pmxlocal" {
  count                 = var.pmxservices == true ? 1 : 0
  name                = "scw"
  zone_name           = azurerm_private_dns_zone.pmxlocal_dnszone[count.index].name
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  ttl                 = 300
  records             = tolist([ for inst in azurerm_network_interface.security_console : inst.ip_configuration.0.private_ip_address ])
}
