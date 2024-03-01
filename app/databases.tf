
# database has to be created for managed instance for the install shield to work

resource "azurerm_mssql_managed_database" "pmxsysdb_database" {
  name                = "MRISystem${var.identifier}pmx${var.datacenter}${var.environment}"
  managed_instance_id = data.azurerm_mssql_managed_instance.pmx_sqlmi.id
}

resource "azurerm_mssql_managed_database" "pmxstatedb_database" {
  name                = "MRIWebState${var.identifier}pmx${var.datacenter}${var.environment}"
  managed_instance_id = data.azurerm_mssql_managed_instance.pmx_sqlmi.id
}

#######################################################################################
###########                    database  entitity                          ############
########### This is moved to here from configtable for easy destroy cycles ############
###########                                                                ############

resource "azurerm_storage_table_entity" "pmxappcomponent_systemdbentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_DBConfigTable.name

  partition_key = "systemDB"
  row_key       = var.LongEnvironmentName

  entity = {
    instancename          = data.azurerm_mssql_managed_instance.pmx_sqlmi.name
    instancefqdn          = data.azurerm_mssql_managed_instance.pmx_sqlmi.fqdn,
    databasename          = azurerm_mssql_managed_database.pmxsysdb_database.name,
    username              = var.db_admin_username,
    keyvault              = var.syscredKeyvault_name,
    secret                = var.db_admin_password_secret,
    instanceResourceGroup = data.azurerm_mssql_managed_instance.pmx_sqlmi.resource_group_name
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_statedbentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_DBConfigTable.name

  partition_key = "stateDB"
  row_key       = var.LongEnvironmentName

  entity = {
    instancename          = data.azurerm_mssql_managed_instance.pmx_sqlmi.name
    instancefqdn          = data.azurerm_mssql_managed_instance.pmx_sqlmi.fqdn,
    databasename          = azurerm_mssql_managed_database.pmxstatedb_database.name,
    username              = var.db_admin_username,
    keyvault              = var.syscredKeyvault_name,
    secret                = var.db_admin_password_secret,
    instanceResourceGroup = data.azurerm_mssql_managed_instance.pmx_sqlmi.resource_group_name

  }
}

###########                                                                ############ 
###########                                                                ############ 
###########                   End of database entitity                     ############
#######################################################################################
