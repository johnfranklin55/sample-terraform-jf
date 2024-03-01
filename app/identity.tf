# resource "azurerm_user_assigned_identity" "pmxappst_Identity" {
#   resource_group_name      = azurerm_resource_group.pmxapp_rg.name
#   location                 = azurerm_resource_group.pmxapp_rg.location

#   name = "${var.LongEnvironmentName}-identity"
# }

data "azurerm_user_assigned_identity" "environment_identity" {
  name                = var.environment_foundation_identity_name
  # resource_group_name = var.environment_foundation_identity_resourceGroup
  resource_group_name = var.environment_resourcegroup
}

resource "azurerm_role_assignment" "pmxappst_tablecontributor_roleassignment" {
  scope                = azurerm_storage_account.pmxapp_storageaccount.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = data.azurerm_user_assigned_identity.environment_identity.principal_id
}

resource "azurerm_role_assignment" "pmxappst_reader_roleassignment" {
  scope                = azurerm_storage_account.pmxapp_storageaccount.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.environment_identity.principal_id
}

resource "azurerm_role_assignment" "pmxappst_contributor_roleassignment" {
  scope                = azurerm_storage_account.pmxapp_storageaccount.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.environment_identity.principal_id
}
