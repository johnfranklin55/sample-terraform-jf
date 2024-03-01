
resource "azurerm_storage_account" "pmxapp_storageaccount" {
  name                     = "st${var.datacenter}${var.environment}pmx%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}"
  resource_group_name      = azurerm_resource_group.pmxapp_rg.name
  location                 = azurerm_resource_group.pmxapp_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
