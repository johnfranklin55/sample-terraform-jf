
resource "azurerm_storage_table" "configsettings_table" {
  name                 = "${var.datacenter}${var.environment}ConfigurationSettings"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}

resource "azurerm_storage_table_entity" "cleanupsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "cleanup"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.config.cleanup
  }
}

resource "azurerm_storage_table_entity" "environmentkeyvault_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "environmentKeyvault"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.config_environment_keyvault_name
  }
}

resource "azurerm_storage_table_entity" "syscredkeyvault_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "syscredKeyvault"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.syscredKeyvault_name
  }
}

resource "azurerm_storage_table_entity" "loglevelsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "loglevel"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.config.loglevel
  }
}

resource "azurerm_storage_table_entity" "configrunsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "configrun"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.config.configrun
  }
}

resource "azurerm_storage_table_entity" "configrunsetting_azfileshare" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "azfileshare"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.azfileshare
  }
}

resource "azurerm_storage_table_entity" "packagenamesetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "packagename"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.package_name
  }
}

resource "azurerm_storage_table_entity" "packageversionsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "packageversion"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.package_version
  }
}

resource "azurerm_storage_table_entity" "forceupdatepackagesetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "forceUpdatePackageName"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.force_update_package_name
  }
}


resource "azurerm_storage_table_entity" "forceupdateversionsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "forceUpdatePackageVersion"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.force_update_package_version
  }
}


resource "azurerm_storage_table_entity" "pmxservicessetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "pmxservices"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.pmxservices
  }
}

resource "azurerm_storage_table_entity" "platformxsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "platformx"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.platform_x
  }
}

resource "azurerm_storage_table_entity" "serviceRegistrationsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "serviceRegistration"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.config.serviceRegistration
  }
}

resource "azurerm_storage_table_entity" "SSLConfigsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "SSLConfig"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.config.SSLConfig
  }
}

resource "azurerm_storage_table_entity" "externalSubdomainsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "externalSubdomain"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.external_subdomain
  }
}

resource "azurerm_storage_table_entity" "externalRootDomainsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "externalRootDomain"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.external_root_domain
  }
}

########################################################################################
############              priamary app settign entitity                     ############
############ This is moved to the primary_app file for easy destroy cycles  ############
############                                                                ############

# resource "azurerm_storage_table_entity" "primaryappsetting_entity" {
#   storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
#   table_name           = azurerm_storage_table.configsettings_table.name

#   partition_key = "PrimaryApp"
#   row_key       = var.LongEnvironmentName

#   entity = {
#     value     = azurerm_windows_virtual_machine.primary_app.computer_name
#   }
# }

############                                                                ############ 
############                                                                ############ 
############              End of priamary app settign entitity              ############
########################################################################################

resource "azurerm_storage_table_entity" "ADDomainsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.configsettings_table.name

  partition_key = "ADDomain"
  row_key       = var.LongEnvironmentName

  entity = {
    value     = var.domain.main.name
  }
}

resource "azurerm_storage_table" "pmxappcomponents_table" {
  name                 = "${var.datacenter}${var.environment}Components"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}

resource "azurerm_storage_table_entity" "pmxappcomponent_paentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "pa"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.primary_app_count,
    role        = "PrimaryApp"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_saentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "sa"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.secondary_app_count,
    role        = "SecondaryApp"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_wsentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "ws"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.web_count,
    role        = "Web"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_apientity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "api"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.api_count,
    role        = "Api"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_scwentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "scw"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.security_console_count,
    role        = "SecurityConsole"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_wientity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "wi"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.windows_count,
    role        = "Windows"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_susentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "sus"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = var.core_sus_count,
    role        = "Sus"
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_wimentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxappcomponents_table.name

  partition_key = "wim"
  row_key       = var.LongEnvironmentName

  entity = {
    ServerCount = "1",
    role        = "WindowsManagement"
  }
}


### database config table
resource "azurerm_storage_table" "pmxapp_DBConfigTable" {
  name                 = "${var.datacenter}${var.environment}DBConfig"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}

########################################################################################
############                    database  entitity                          ############
############  This is moved to the database file for easy destroy cycles    ############
############                                                                ############

# resource "azurerm_storage_table_entity" "pmxappcomponent_systemdbentity" {
#   storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
#   table_name           = azurerm_storage_table.pmxapp_DBConfigTable.name

#   partition_key = "systemDB"
#   row_key       = var.LongEnvironmentName

#   entity = {
#     instancename          = data.azurerm_mssql_managed_instance.pmx_sqlmi.name
#     instancefqdn          = data.azurerm_mssql_managed_instance.pmx_sqlmi.fqdn,
#     databasename          = azurerm_mssql_managed_database.pmxsysdb_database.name,
#     username              = var.db_admin_username,
#     keyvault              = var.syscredKeyvault_name,
#     secret                = var.db_admin_password_secret,
#     instanceResourceGroup = data.azurerm_mssql_managed_instance.pmx_sqlmi.resource_group_name
#   }
# }

# resource "azurerm_storage_table_entity" "pmxappcomponent_statedbentity" {
#   storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
#   table_name           = azurerm_storage_table.pmxapp_DBConfigTable.name

#   partition_key = "stateDB"
#   row_key       = var.LongEnvironmentName

#   entity = {
#     instancename          = data.azurerm_mssql_managed_instance.pmx_sqlmi.name
#     instancefqdn          = data.azurerm_mssql_managed_instance.pmx_sqlmi.fqdn,
#     databasename          = azurerm_mssql_managed_database.pmxstatedb_database.name,
#     username              = var.db_admin_username,
#     keyvault              = var.syscredKeyvault_name,
#     secret                = var.db_admin_password_secret,
#     instanceResourceGroup = data.azurerm_mssql_managed_instance.pmx_sqlmi.resource_group_name

#   }
# }

############                                                                ############ 
############                                                                ############ 
############                   End of database entitity                     ############
########################################################################################


resource "azurerm_storage_table" "pmxapp_FileShareConfigTable" {
  name                 = "${var.datacenter}${var.environment}FileShareConfig"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}

resource "azurerm_storage_table_entity" "pmxappcomponent_filesharestentity" {
  count                = var.azfileshare == true ? 1 : 0
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_FileShareConfigTable.name

  partition_key = "storageAccount"
  row_key       = var.LongEnvironmentName

  entity = {
    value = "stpmx%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}${var.datacenter}${var.azfileshare_storage_random_id}"
  }
}

resource "azurerm_storage_table_entity" "FileShareConfig_fileshareentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_FileShareConfigTable.name

  partition_key = "fileShare"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.azfileshare == true ? "fs-${var.datacenter}-${var.environment}-pmx-%{if var.pmx_core}core%{else}flex%{endif}-${var.identifier}" : "fs%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}${var.datacenter}${var.azfileshare_storage_random_id}"
  }
}

resource "azurerm_storage_table_entity" "FileShareConfig_fileshare_path_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_FileShareConfigTable.name

  partition_key = "path"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.azfileshare == true ? "${var.datacenter}-${var.environment}-pmxfileshare.privatelink.file.core.windows.net\\fs-${var.datacenter}-${var.environment}-pmx-%{if var.pmx_core}core%{else}flex%{endif}-${var.identifier}" : "fs%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}${var.datacenter}${var.azfileshare_storage_random_id}"
  }
}

resource "azurerm_storage_table_entity" "FileShareConfig_azfileshare_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_FileShareConfigTable.name

  partition_key = "azfileshare"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.azfileshare
  }
}

resource "azurerm_storage_table_entity" "FileShareConfig_filesharerg_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_FileShareConfigTable.name

  partition_key = "fileshareResourceGroup"
  row_key       = var.LongEnvironmentName

  entity = {
    value = data.azurerm_storage_account.pmx_fsst.resource_group_name
  }
}


resource "azurerm_storage_table" "pmxapp_DomainConfigTable" {
  name                 = "${var.datacenter}${var.environment}DomainConfig"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}

resource "azurerm_storage_table_entity" "pmxappcomponent_domainentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_DomainConfigTable.name

  partition_key = "ADDomain"
  row_key       = var.LongEnvironmentName

  entity = {
    value = var.domain.main.name
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_MRIWebServiceUserentity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_DomainConfigTable.name

  partition_key = "MRIWebServiceUser"
  row_key       = var.LongEnvironmentName

  entity = {
    name     = var.pmx_domain_service_user,
    secret   = var.pmx_domain_service_secret,
    keyvault = var.syscredKeyvault_name
  }
}

resource "azurerm_storage_table_entity" "subdomainsetting_entity" {
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_DomainConfigTable.name

  partition_key = "subdomain"
  row_key       = var.LongEnvironmentName

  entity = {
    value     = split(".", var.domain.main.name)[0]
  }
}


resource "azurerm_storage_table" "pmxapp_ServicesConfigTable" {
  name                 = "${var.datacenter}${var.environment}ServicesConfig"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}

resource "azurerm_storage_table_entity" "pmxappcomponent_pmxenvserviceentity" {
  count                 = var.pmxservices == true ? 1 : 0
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_ServicesConfigTable.name

  partition_key = "pmxenvservice"
  row_key       = var.LongEnvironmentName

  entity = {
    url      = jsondecode(data.azapi_resource.pmxenvservice_container_app[count.index].output).properties.configuration.ingress.fqdn
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_pmxdbserviceentity" {
  count                 = var.pmxservices == true ? 1 : 0
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_ServicesConfigTable.name

  partition_key = "pmxdbservice"
  row_key       = var.LongEnvironmentName

  entity = {
    url      = jsondecode(data.azapi_resource.pmxdbservice_container_app[count.index].output).properties.configuration.ingress.fqdn
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_pmxfileserviceentity" {
  count                 = var.pmxservices == true ? 1 : 0
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_ServicesConfigTable.name

  partition_key = "pmxfileservice"
  row_key       = var.LongEnvironmentName

  entity = {
    url      = jsondecode(data.azapi_resource.pmxfileservice_container_app[count.index].output).properties.configuration.ingress.fqdn
  }
}

resource "azurerm_storage_table_entity" "pmxappcomponent_pmxdashserviceentity" {
  count                 = var.pmxservices == true ? 1 : 0  
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
  table_name           = azurerm_storage_table.pmxapp_ServicesConfigTable.name

  partition_key = "pmxdashservice"
  row_key       = var.LongEnvironmentName

  entity = {
    url      = jsondecode(data.azapi_resource.pmxdashservice_container_app[count.index].output).properties.configuration.ingress.fqdn
  }
}


resource "azurerm_storage_table" "pmxapp_ConfigStateTable" {
  name                 = "${var.datacenter}${var.environment}ConfigState"
  storage_account_name = azurerm_storage_account.pmxapp_storageaccount.name
}
