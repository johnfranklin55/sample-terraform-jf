locals {
  # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
  asg_resource_id_regex  = "^/subscriptions/(?P<subscription_id>[-[:xdigit:]+]+)/resourceGroups/(?P<resource_group_name>[-\\w\\._\\(\\)]+)/providers/Microsoft.Network/applicationSecurityGroups/(?P<name>[[:alnum:]\\._-]+)$"
  nsg_resource_id_regex  = "^/subscriptions/(?P<subscription_id>[-[:xdigit:]+]+)/resourceGroups/(?P<resource_group_name>[-\\w\\._\\(\\)]+)/providers/Microsoft.Network/networkSecurityGroups/(?P<name>[[:alnum:]\\._-]+)$"
  vnet_resource_id_regex = "^/subscriptions/(?P<subscription_id>[-[:xdigit:]+]+)/resourceGroups/(?P<resource_group_name>[-\\w\\._\\(\\)]+)/providers/Microsoft.Network/virtualNetworks/(?P<name>[[:alnum:]][[:alnum:]\\._-]*?[[:alnum:]_]+)$"
  subnet_id_regex        = "^/subscriptions/(?P<subscription_id>[-[:xdigit:]+]+)/resourceGroups/(?P<resource_group_name>[-\\w\\._\\(\\)]+)/providers/Microsoft.Network/virtualNetworks/(?P<virtual_network_name>[[:alnum:]][[:alnum:]\\._-]*?[[:alnum:]_]+)/subnets/(?P<name>[[:alnum:]][[:alnum:]\\._-]*?[[:alnum:]_]+)$"
  delegated_subnet_names = [
    "azurebastionsubnet",
    "gatewaysubnet",
    "azurefirewallsubnet"
  ]

  common_tags = merge(
    var.tags,
    {
      BuiltBy         = "Terraform"
    #   TerraformModule = "https://dev.azure.com/mrisoftware/CCoE/_git/terraform-azurerm-virtual-network"
    }
  )
}

locals {
  snet = "snet-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}"
  vnet = "vnet-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}"

  application_security_groups = {
    api              = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-api",
    app_primary      = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-primary_app",
    app_secondary    = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-secondary_app",
    security_console = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-security_console",
    sql_app          = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-app_sql",
    sql_app_test     = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-app_test_sql",
    sql_system       = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-system_sql",
    web              = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-web",
    windows          = "asg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-windows"
  }

  core_application_security_groups = {
    sus = "asg-${var.datacenter}-${var.environment}-pmx_core_${var.identifier}-sus"
  }
}

locals {
  subnet_id = azurerm_subnet.pmxapp_subnet.id
}


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           VIRTUAL NETWORK                                    #
#                                                              #

# +++++++++++++++++++++++++++++++++++++++++++++++ #
#            VNET                                 #
#                                                 #

resource "azurerm_virtual_network" "pmxapp_vnet" {
  name                = local.vnet
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  location            = azurerm_resource_group.pmxapp_rg.location
  address_space       = var.network.app_virtual_network_address_space

  dns_servers = []
  
  tags = merge(
    local.common_tags,
    var.tags
  )
}

# +++++++++++++++++++++++++++++++++++++++++++++++ #
#            VNET Peering                         #
#                                                 #

### netsec peering
data "azurerm_virtual_network" "netsec" {
  name                = var.network.netsec_name
  resource_group_name = var.network.netsec_resourcegroup
}

resource "azurerm_virtual_network_peering" "pmxapp_netsec_peer" {
  name                      = "app-netsec-${var.datacenter}${var.environment}-connectivity"
  resource_group_name       = azurerm_virtual_network.pmxapp_vnet.resource_group_name
  virtual_network_name      = azurerm_virtual_network.pmxapp_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.netsec.id

  allow_forwarded_traffic   = true
}


resource "azurerm_virtual_network_peering" "netsec_pmxapp_peer" {
  name                      = "netsec-app-${var.datacenter}${var.environment}-connectivity"
  resource_group_name       = data.azurerm_virtual_network.netsec.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.netsec.name
  remote_virtual_network_id = azurerm_virtual_network.pmxapp_vnet.id

  allow_gateway_transit   = true
  allow_forwarded_traffic = true
}

### central hub connectivity peering
data "azurerm_virtual_network" "central_hub" {
  count               = var.network.central_hub_connectivity == true ? 1 : 0
  provider            = azurerm.central-hub-subscription
  name                = var.network.central_hub_name
  resource_group_name = var.network.central_hub_resourcegroup
}

resource "azurerm_virtual_network_peering" "centralhub_pmxapp_peer" {
  count                     = var.network.central_hub_connectivity == true ? 1 : 0
  provider                  = azurerm.central-hub-subscription
  name                      = "centralhub-pmxapp-${var.datacenter}${var.environment}-connectivity"
  resource_group_name       = data.azurerm_virtual_network.central_hub[count.index].resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.central_hub[count.index].name
  remote_virtual_network_id = azurerm_virtual_network.pmxapp_vnet.id

  allow_gateway_transit   = true
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "pmxapp_centralhub_peer" {
  count                     = var.network.central_hub_connectivity == true ? 1 : 0
  name                      = "pmxapp-centralhub-${var.datacenter}${var.environment}-connectivity"
  resource_group_name       = azurerm_virtual_network.pmxapp_vnet.resource_group_name
  virtual_network_name      = azurerm_virtual_network.pmxapp_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.central_hub[count.index].id

  allow_forwarded_traffic   = true
}


#                                                 #
#      END VNET Peering                           #
# +++++++++++++++++++++++++++++++++++++++++++++++ #

#                                                              #
#           END VIRTUAL NETWORK                                #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#      SECURITY GROUPS                                                              #
#                                                                                   #

# # +++++++++++++++++++++++++++++++++++++++++++++++ #
# #      Application SECURITY GROUPS                #
# #                                                 #



# #      END Application SECURITY GROUPS            #
# #                                                 #
# # +++++++++++++++++++++++++++++++++++++++++++++++ #


# # +++++++++++++++++++++++++++++++++++++++++++++++ #
# #      Network SECURITY GROUPS                    #
# #                                                 #


# #      END Network SECURITY GROUPS                #
# #                                                 #
# # +++++++++++++++++++++++++++++++++++++++++++++++ #


#                                                                         #
#      END SECURITY GROUPS                                                #
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #



# +++++++++++++++++++++++++++++++++++++++++++++++ #
#                 Subnets                         #
#          

resource "azurerm_subnet" "pmxapp_subnet" {
  name = local.snet
  resource_group_name  = azurerm_virtual_network.pmxapp_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.pmxapp_vnet.name
  address_prefixes     = [var.network.app_subnet_address_space.0]
}

resource "azurerm_subnet" "pmxappgw_subnet" {
  name = "AppgatewaySubnet"
  resource_group_name   = azurerm_virtual_network.pmxapp_vnet.resource_group_name
  virtual_network_name  = azurerm_virtual_network.pmxapp_vnet.name
  address_prefixes      = [var.network.app_subnet_address_space.1]
}

#                                                 #
#                  END Subnets                    #
# +++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           Route Tables                                           #
#          


# ++++++++++++++++++++++++++++++++++++++++++++++ #
#     ROUTE TABLES                               #
#                                                #

resource "azurerm_route_table" "pmxapp_rt" {
  name                          = "rt-${local.snet}"
  location                      = var.location
  resource_group_name           = azurerm_virtual_network.pmxapp_vnet.resource_group_name
  disable_bgp_route_propagation = false

  tags = merge(
    local.common_tags,
    var.tags
  )
}

resource "azurerm_route" "rt-defaultroute" {
  name                    = "rt-defaultroute"
  resource_group_name     = azurerm_resource_group.pmxapp_rg.name
  route_table_name        = azurerm_route_table.pmxapp_rt.name
  address_prefix          = "0.0.0.0/0"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = var.network.egress_gateway_address
}

### platform x routes
resource "azurerm_route" "rt-app-platformx" {
  count                   = var.platform_x == true ? 1 : 0    
  name                    = "rt-app-platformx"
  resource_group_name     = "rg-ue01-qa05-pmx_core_x5-app"
  route_table_name        = "rt-snet-ue01-qa05-pmx_core_x5"
  address_prefix          = "10.104.134.0/24"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = var.network.egress_gateway_address
}

### qa central adds routes
resource "azurerm_route" "rt-central-adds" {
  count                   = var.network.central_hub_connectivity == true ? 1 : 0   
  name                    = "rt-central-adds"
  resource_group_name     = azurerm_resource_group.pmxapp_rg.name
  route_table_name        = azurerm_route_table.pmxapp_rt.name
  address_prefix          = "10.104.24.0/21"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = "10.104.0.74"
}

### solon routes
resource "azurerm_route" "rt-solon" {
  count                   = var.network.central_hub_connectivity == true ? 1 : 0   
  name                    = "rt-solon"
  resource_group_name     = azurerm_resource_group.pmxapp_rg.name
  route_table_name        = azurerm_route_table.pmxapp_rt.name
  address_prefix          = "172.30.128.0/18"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = "10.104.0.74"
}

#                                                #
#     END ROUTE TABLES                           #
# ++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++ #
#     ROUTE TABLE ASSOCIATIONS                   #
#                                                #

resource "azurerm_subnet_route_table_association" "this" {
  subnet_id      = azurerm_subnet.pmxapp_subnet.id
  route_table_id = azurerm_route_table.pmxapp_rt.id
}

#                                                #
#     END ROUTE TABLE ASSOCIATIONS               #
# ++++++++++++++++++++++++++++++++++++++++++++++ #

#                                                                  #
#      END Route Tables                                            #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #







