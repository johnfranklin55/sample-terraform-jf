# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "api" {
  count               = var.api_count
  name                = "nic-${var.datacenter}${var.environment}api${count.index+1}${random_id.api[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}api${count.index+1}${random_id.api[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "primary_app" {
  count               = var.primary_app_count
  name                = "nic-${var.datacenter}${var.environment}pa${count.index+1}${random_id.primary_app[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}pa${count.index+1}${random_id.primary_app[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "secondary_app" {
  count               = var.secondary_app_count
  name                = "nic-${var.datacenter}${var.environment}sa${count.index+1}${random_id.secondary_app[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}sa${count.index+1}${random_id.secondary_app[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "security_console" {
  count               = var.security_console_count
  name                = "nic-${var.datacenter}${var.environment}scw${count.index+1}${random_id.security_console[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}scw${count.index+1}${random_id.security_console[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "core-sus" {
  count               = var.pmx_core == true ? var.core_sus_count : 0
  name                = "nic-${var.datacenter}${random_id.core-sus[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${random_id.core-sus[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "web" {
  count               = var.web_count
  name                = "nic-${var.datacenter}${var.environment}ws${count.index+1}${random_id.web[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}ws${count.index+1}${random_id.web[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

# Build primary NIC
#
resource "azurerm_network_interface" "wim" {
  name                = "nic-${var.datacenter}${var.environment}wim01${random_id.wim.hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}wim01${random_id.wim.hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "windows" {
  count               = var.windows_count
  name                = "nic-${var.datacenter}${var.environment}wi${count.index+1}${random_id.windows[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}wi${count.index+1}${random_id.windows[count.index].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = var.domain["main"].dns_servers

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

