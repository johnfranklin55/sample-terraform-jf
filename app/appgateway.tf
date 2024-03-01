

locals {
  appgateway_components = "${azurerm_virtual_network.pmxapp_vnet.name}"
  # backend_address_pool_name      = "${azurerm_virtual_network.pmxapp_vnet.name}-beap"
  # frontend_port_name             = "${azurerm_virtual_network.pmxapp_vnet.name}-feport"
  # frontend_ip_configuration_name = "${azurerm_virtual_network.pmxapp_vnet.name}-feip"
  # http_setting_name              = "${azurerm_virtual_network.pmxapp_vnet.name}-be-htst"
  # listener_name                  = "${azurerm_virtual_network.pmxapp_vnet.name}-httplstn"
  # request_routing_rule_name      = "${azurerm_virtual_network.pmxapp_vnet.name}-rqrt"
  # redirect_configuration_name    = "${azurerm_virtual_network.pmxapp_vnet.name}-rdrcfg"
  # url_path_map_name              = "${azurerm_virtual_network.pmxapp_vnet.name}-path-map"

  diag_appgw_logs = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog",
  ]
  diag_appgw_metrics = [
    "AllMetrics",
  ]

  root_domain = "${var.external_root_domain}"

  app_gw_api_host_names = [
    "${var.datacenter}${var.environment}-api.${var.external_subdomain}."
  ]
  app_gw_web_host_names = [
    "${var.datacenter}${var.environment}-web.${var.external_subdomain}."
  ]
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#               Log Analytics Workspace                        #
#                                                              #

resource "azurerm_log_analytics_workspace" "pmxapp_appgw_logaw" {
  name                = "${var.datacenter}${var.environment}-pmx-logaw"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  sku                 = "PerGB2018" #(Required) Specifies the Sku of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, and PerGB2018 (new Sku as of 2018-04-03).
  retention_in_days   = 100         #(Optional) The workspace data retention in days. Possible values range between 30 and 730.
  tags                = local.tags
}

resource "azurerm_log_analytics_solution" "pmxapp_appgw_lasolution" {
  solution_name         = "AzureAppGatewayAnalytics"
  location              = azurerm_resource_group.pmxapp_rg.location
  resource_group_name   = azurerm_resource_group.pmxapp_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.pmxapp_appgw_logaw.id
  workspace_name        = azurerm_log_analytics_workspace.pmxapp_appgw_logaw.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureAppGatewayAnalytics"
  }
}

#                                                              #
#               END Log Analytics Workspace                    #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#               Managed Service Identity                       #
#                                                              #

data "azurerm_user_assigned_identity" "pmxapp_appgw_identity" {
#   provider            = azurerm.globalResources_subscription
  name                = var.pmx_appgw_muid.name
  resource_group_name = var.environment_resourcegroup
}

#                                                              #
#               END Managed Service Identity                   #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                 Certificate Keyvault                         #
#                                                              #

data "azurerm_key_vault" "pmxapp_appgw_keyvault" {
#   provider            = azurerm.globalResources_subscription
  name                = var.pmx_cert.keyvault_name
  resource_group_name = var.environment_resourcegroup
}

data "azurerm_key_vault_certificate" "pmxapp_appgw_certificate_pmxapp_web" {
#   provider     = azurerm.globalResources_subscription
  name         = var.pmx_cert.certificate_name
  key_vault_id = data.azurerm_key_vault.pmxapp_appgw_keyvault.id
}

#                                                              #
#                 END Certificate Keyvault                     #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        Public IP                                             #
#                                                              #

resource "azurerm_public_ip" "pmxapp_appgw_pip" {
  name                = "${var.datacenter}${var.environment}-pmx-appgateway-pip"
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  location            = azurerm_resource_group.pmxapp_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags                = local.tags
}

#                                                              #
#        END Public IP                                         #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#             application gateway                              #
#                                                              #

# ++++++++++++++++++++++++++++++++++++++++++ #
#             application gateway            #
#                                            #

resource "azurerm_application_gateway" "pmxapp_appgw" {
  name                = "${var.datacenter}${var.environment}-pmx-appgateway"
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  location            = azurerm_resource_group.pmxapp_rg.location

  enable_http2        = true
  zones               = ["1", "2", "3"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.

  sku {
    name     = "WAF_v2"  #Sku with WAF ? WAF_v2 : Standard_v2
    tier     = "WAF_v2"
    # capacity = 2
  }

  autoscale_configuration {
    min_capacity = 1  # Minimum capacity for autoscaling. Accepted values are in the range 0 to 100.
    max_capacity = 2  # Maximum capacity for autoscaling. Accepted values are in the range 2 to 125.
  }

  gateway_ip_configuration {
    name      = "${var.datacenter}${var.environment}-pmx-appgateway-ip-configuration"
    subnet_id = azurerm_subnet.pmxappgw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "${local.appgateway_components}-feip-public"
    public_ip_address_id = azurerm_public_ip.pmxapp_appgw_pip.id
  }

  frontend_port {
    name = "${local.appgateway_components}-feport-80"
    port = 80
  }

    frontend_port {
    name = "${local.appgateway_components}-feport-443"
    port = 443
  }

  backend_address_pool {
    name = "${local.appgateway_components}-beap-api"
    }

  backend_address_pool {
    name = "${local.appgateway_components}-beap-web"
    # ip_addresses = tolist([ for inst in azurerm_network_interface.web : inst.ip_configuration.0.private_ip_address ])
  }

  backend_address_pool {
    name = "${local.appgateway_components}-beap-scw"
  }

  backend_http_settings {
    name                  = "${local.appgateway_components}-be-htst"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    # host_name             = local.backend_address_pool.fqdns[0]
    request_timeout       = 60
  }

  ssl_certificate {
    name                = data.azurerm_key_vault_certificate.pmxapp_appgw_certificate_pmxapp_web.name
    key_vault_secret_id = data.azurerm_key_vault_certificate.pmxapp_appgw_certificate_pmxapp_web.secret_id
  }

  http_listener {
    name                           = "${local.appgateway_components}-httplstn-http-api"
    frontend_ip_configuration_name = "${local.appgateway_components}-feip-public"
    frontend_port_name             = "${local.appgateway_components}-feport-80"
    protocol                       = "Http"
    host_names                     = formatlist("%s%s", local.app_gw_api_host_names, local.root_domain)
  }

  http_listener {
    name                           = "${local.appgateway_components}-httplstn-https-api"
    frontend_ip_configuration_name = "${local.appgateway_components}-feip-public"
    frontend_port_name             = "${local.appgateway_components}-feport-443"
    protocol                       = "Https"
    ssl_certificate_name           = data.azurerm_key_vault_certificate.pmxapp_appgw_certificate_pmxapp_web.name
    host_names                     = formatlist("%s%s", local.app_gw_api_host_names, local.root_domain)
  }

  http_listener {
    name                           = "${local.appgateway_components}-httplstn-http-web"
    frontend_ip_configuration_name = "${local.appgateway_components}-feip-public"
    frontend_port_name             = "${local.appgateway_components}-feport-80"
    protocol                       = "Http"
    host_names                     = formatlist("%s%s", local.app_gw_web_host_names, local.root_domain)
  }

  http_listener {
    name                           = "${local.appgateway_components}-httplstn-https-web"
    frontend_ip_configuration_name = "${local.appgateway_components}-feip-public"
    frontend_port_name             = "${local.appgateway_components}-feport-443"
    protocol                       = "Https"
    ssl_certificate_name           = data.azurerm_key_vault_certificate.pmxapp_appgw_certificate_pmxapp_web.name
    host_names                     = formatlist("%s%s", local.app_gw_web_host_names, local.root_domain)
  }

  request_routing_rule {
    name                        = "${local.appgateway_components}-rqrt-http-redirect-api"
    rule_type                   = "Basic"
    http_listener_name          = "${local.appgateway_components}-httplstn-http-api"
    redirect_configuration_name = "${local.appgateway_components}-rdrcfg-api"
    priority                    = 110
  }

  request_routing_rule {
    name                       = "${local.appgateway_components}-rqrt-https-api"
    rule_type                  = "Basic"
    http_listener_name         = "${local.appgateway_components}-httplstn-https-api"
    backend_address_pool_name  = "${local.appgateway_components}-beap-api"
    backend_http_settings_name = "${local.appgateway_components}-be-htst"
    priority                   = 120
  }

  request_routing_rule {
    name                        = "${local.appgateway_components}-rqrt-http-redirect-web"
    rule_type                   = "Basic"
    http_listener_name          = "${local.appgateway_components}-httplstn-http-web"
    redirect_configuration_name = "${local.appgateway_components}-rdrcfg-web"
    priority                    = 130
  }

  request_routing_rule {
    name                       = "${local.appgateway_components}-rqrt-https-web"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "${local.appgateway_components}-httplstn-https-web"
    backend_address_pool_name  = "${local.appgateway_components}-beap-web"
    backend_http_settings_name = "${local.appgateway_components}-be-htst"
    url_path_map_name          = "${local.appgateway_components}-path-map-web"
    priority                   = 140
  }

  # request_routing_rule {
  #   name                       = "${local.appgateway_components}-rqrt-https-web"
  #   rule_type                  = "Basic"
  #   http_listener_name         = "${local.appgateway_components}-httplstn-https-web"
  #   backend_address_pool_name  = "${local.appgateway_components}-beap-web"
  #   backend_http_settings_name = "${local.appgateway_components}-be-htst"
  #   priority                   = 150
  # }

  # url_path_map {
  #   name                               = "${local.url_path_map_name}-path-map-api"
  #   default_backend_http_settings_name = local.appgateway_components
  #   default_backend_address_pool_name  = "${local.appgateway_components}-beap-api"
  #   path_rule {
  #     name                       = "${local.url_path_map_name}-path-rule-api"
  #     backend_http_settings_name = local.appgateway_components
  #     backend_address_pool_name  = "${local.appgateway_components}-beap-api"
  #     paths = [
  #       "/MRIWeb/MRIAPIServices/*"
  #     ]
  #   }
  # }

  # url_path_map {
  #   name                               = "${local.url_path_map_name}-path-map-web"
  #   default_backend_http_settings_name = local.appgateway_components
  #   default_backend_address_pool_name  = "${local.appgateway_components}-beap-web"
  #   path_rule {
  #     name                       = "${local.url_path_map_name}-path-rule-web"
  #     backend_http_settings_name = local.appgateway_components
  #     backend_address_pool_name  = "${local.appgateway_components}-beap-web"
  #     paths = [
  #       "/MRIWeb/MRIWebServices/*",
  #       "/MRIWeb/ldp/*"
  #     ]
  #   }
  # }

  url_path_map {
    name                               = "${local.appgateway_components}-path-map-web"
    default_backend_http_settings_name = "${local.appgateway_components}-be-htst"
    default_backend_address_pool_name  = "${local.appgateway_components}-beap-web"
    path_rule {
      name                       = "${local.appgateway_components}-path-rule-web-scw"
      backend_http_settings_name = "${local.appgateway_components}-be-htst"
      backend_address_pool_name  = "${local.appgateway_components}-beap-scw"
      paths = [
        "/MRIWeb/SecurityConsole/*"
      ]
    }
  }

  redirect_configuration {
    name                 = "${local.appgateway_components}-rdrcfg-api"
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = "${local.appgateway_components}-httplstn-https-api"
  }

  redirect_configuration {
    name                 = "${local.appgateway_components}-rdrcfg-web"
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = "${local.appgateway_components}-httplstn-https-web"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.pmxapp_appgw_identity.id]
  }

  # // Ignore most changes as they will be managed manually
  # lifecycle {
  #   ignore_changes = [
  #     # backend_address_pool,
  #     # backend_http_settings,
  #     # frontend_port,
  #     # http_listener,
  #     probe,
  #     # request_routing_rule,
  #     url_path_map,
  #     # ssl_certificate,
  #     # redirect_configuration,
  #     # autoscale_configuration
  #   ]
  # }

}

#                                            #
#        END  application gateway            #
# ++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++ #
#     backend adress pool association        #
#                                            #

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgateway_api_beassc" {
  count                   = var.api_count
  network_interface_id    = azurerm_network_interface.api[count.index].id
  ip_configuration_name   = tolist(azurerm_network_interface.api[count.index].ip_configuration).0.name
  backend_address_pool_id = tolist(azurerm_application_gateway.pmxapp_appgw.backend_address_pool).*.id[index(azurerm_application_gateway.pmxapp_appgw.backend_address_pool.*.name, "${local.appgateway_components}-beap-api")]
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgateway_web_beassc" {
  count                   = var.web_count
  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = tolist(azurerm_network_interface.web[count.index].ip_configuration).0.name
  backend_address_pool_id = tolist(azurerm_application_gateway.pmxapp_appgw.backend_address_pool).*.id[index(azurerm_application_gateway.pmxapp_appgw.backend_address_pool.*.name, "${local.appgateway_components}-beap-web")]
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgateway_scw_beassc" {
  count                   = var.security_console_count
  network_interface_id    = azurerm_network_interface.security_console[count.index].id
  ip_configuration_name   = tolist(azurerm_network_interface.security_console[count.index].ip_configuration).0.name
  backend_address_pool_id = tolist(azurerm_application_gateway.pmxapp_appgw.backend_address_pool).*.id[index(azurerm_application_gateway.pmxapp_appgw.backend_address_pool.*.name, "${local.appgateway_components}-beap-scw")]
}

#                                            #
#     backend adress pool association        #
# ++++++++++++++++++++++++++++++++++++++++++ #

#                                                              #
#        END  application gateway                              #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                   Diagnostic Settings                        #
#                                                              #

resource "azurerm_monitor_diagnostic_setting" "pmxapp_appgw_diagsettings" {
  name                       = "${var.datacenter}${var.environment}-pmx-appgateway-diag"
  target_resource_id         = azurerm_application_gateway.pmxapp_appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.pmxapp_appgw_logaw.id
  dynamic "log" {
    for_each = local.diag_appgw_logs
    content {
      category = log.value

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = local.diag_appgw_metrics
    content {
      category = metric.value

      retention_policy {
        enabled = false
      }
    }
  }
}

#                                                              #
#              END  Diagnostic Settings                        #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
