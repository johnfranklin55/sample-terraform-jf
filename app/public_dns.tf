
# sub-domain records for the Azure App Gateway
resource "azurerm_dns_a_record" "app_gw_api_public_dns" {
  name                = "${var.datacenter}${var.environment}-api"
  zone_name           = "${var.external_subdomain}.${var.external_root_domain}"
  resource_group_name = var.environment_resourcegroup
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.pmxapp_appgw_pip.id
}

resource "azurerm_dns_a_record" "app_gw_web_public_dns" {
  name                = "${var.datacenter}${var.environment}-web"
  zone_name           = "${var.external_subdomain}.${var.external_root_domain}"
  resource_group_name = var.environment_resourcegroup
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.pmxapp_appgw_pip.id
}
