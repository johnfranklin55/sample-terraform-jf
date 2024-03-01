
resource "azurerm_availability_set" "pmx_api" {
  name                        = local.availability_sets.api
  location                    = azurerm_resource_group.pmxapp_rg.location
  resource_group_name         = azurerm_resource_group.pmxapp_rg.name
  platform_fault_domain_count = 2

  tags = local.tags
}


resource "azurerm_availability_set" "secondary_app" {
  name                        = local.availability_sets.secondary_app
  location                    = azurerm_resource_group.pmxapp_rg.location
  resource_group_name         = azurerm_resource_group.pmxapp_rg.name
  platform_fault_domain_count = 2

  tags = local.tags
}


resource "azurerm_availability_set" "pmx_security_console" {
  name                        = local.availability_sets.security_console
  location                    = azurerm_resource_group.pmxapp_rg.location
  resource_group_name         = azurerm_resource_group.pmxapp_rg.name
  platform_fault_domain_count = 2

  tags = local.tags
}



resource "azurerm_availability_set" "pmx_core-sus" {
  name                        = local.core_availability_sets.sus
  location                    = azurerm_resource_group.pmxapp_rg.location
  resource_group_name         = azurerm_resource_group.pmxapp_rg.name
  platform_fault_domain_count = 2

  tags = local.tags
}


resource "azurerm_availability_set" "pmx_web" {
  name                        = local.availability_sets.web
  location                    = azurerm_resource_group.pmxapp_rg.location
  resource_group_name         = azurerm_resource_group.pmxapp_rg.name
  platform_fault_domain_count = 2

  tags = local.tags
}


resource "azurerm_availability_set" "pmx_windows" {
  name                        = local.availability_sets.windows
  location                    = azurerm_resource_group.pmxapp_rg.location
  resource_group_name         = azurerm_resource_group.pmxapp_rg.name
  platform_fault_domain_count = 2

  tags = local.tags
}


