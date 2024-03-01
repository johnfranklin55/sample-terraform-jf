
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# #        VIRTUAL MACHINE     SS                                #
# #                                                              #

# resource "azurerm_orchestrated_virtual_machine_scale_set" "api" {
#   name = "${substr(var.datacenter, 0, 2)}${var.environment}api"
#   location = azurerm_resource_group.pmxapp_rg.location
#   resource_group_name = azurerm_resource_group.pmxapp_rg.name


#   platform_fault_domain_count = 1

#   zones = ["1"]

#   sku_name  = "Standard_D2s_v4"
#   instances = var.api_count

#   source_image_id = var.single_image == true ? (
#     data.azurerm_shared_image_version.pmx-app-image.id
#   ) : (
#     data.azurerm_shared_image_version.pmx-web-image.id
#   )

#   os_profile {
#     windows_configuration {
#       admin_username = "testadmin"
#       admin_password = "testuser@123456"
#     }
#   }
  
#   os_disk {
#     disk_size_gb         = 128 #adding 64 to install pmx on C:\
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }

#   network_interface {
#     name    = "nic-${var.datacenter}api${random_id.api[0].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
#     primary = true

#     ip_configuration {
#       name      = "ipconfig-0-nic-${var.datacenter}${random_id.api[0].hex}-${regex(local.subnet_id_regex, local.subnet_id).name}"
#       primary   = true
#       subnet_id = azurerm_subnet.pmxapp_subnet.id

#       # application_security_group_ids = module.security_groups.application_security_groups[local.application_security_groups.api]  ### depends on network design ###
#     }

#     dns_servers = var.domain["main"].dns_servers
#   }

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [data.azurerm_user_assigned_identity.environment_identity.id]
#   }

#   tags = merge(
#     local.tags,
#     {
#       Role                 = "PMX_API"
#       # UpdateGroup          = count.index == 1 ? 1 : 2
#       Alias                = local.api_alias_tag
#       ConfigStorageAccount = azurerm_storage_account.pmxapp_storageaccount.name
#     }
#   )

#   extension {
#     # count                = var.azfileshare == true ? 1 : 0 #### doesnt support count ####
#     name                 = "CustomScriptExtension"
#     publisher            = "Microsoft.Compute"
#     type                 = "CustomScriptExtension"
#     type_handler_version = "1.9"

#     protected_settings = <<PROTECTEDSETTINGS
#     {
#       "commandToExecute": "powershell -command \"${local.fs_mount_script}\" && powershell -ExecutionPolicy Unrestricted -File fs_mount.ps1 ${data.azurerm_storage_account.pmx_fsst.primary_access_key}"
#     }
#     PROTECTEDSETTINGS
#   }

#   extension {
#     name                 = "DomainJoin"
#     publisher            = "Microsoft.Compute"
#     type                 = "JsonADDomainExtension"
#     type_handler_version = "1.3"
#     extensions_to_provision_after_vm_creation = [
#       "CustomScriptExtension"
#     ]

#     settings = <<SETTINGS
#       {
#         "Name": "${var.domain.main.name}",
#         "User": "${var.domain.main.user}@${var.domain.main.name}",
#         "Restart": "true",
#         "Options": "3"
#       }
#     SETTINGS

#     protected_settings = <<PROTECTED_SETTINGS
#       {
#           "Password": "${var.domain.main.password}"
#       }
#     PROTECTED_SETTINGS
#   }
# }

# #                                                              #
# #        END  VIRTUAL MACHINE  SS                              #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
