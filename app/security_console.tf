

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        VIRTUAL MACHINE                                       #
#                                                              #

resource "azurerm_windows_virtual_machine" "security_console" {
  count = var.security_console_count
  name                = "${var.datacenter}${var.environment}scw${count.index+1}${random_id.security_console[count.index].hex}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  admin_username = var.admin_username
  admin_password = data.azurerm_key_vault_secret.pmx_syscredsecret.value

  availability_set_id = azurerm_availability_set.pmx_security_console.id

  network_interface_ids = [
      azurerm_network_interface.security_console[count.index].id
    ]

  computer_name = "${var.datacenter}${var.environment}scw${count.index+1}${random_id.security_console[count.index].hex}"

  os_disk {
    name                 = "${var.datacenter}${random_id.security_console[count.index].hex}-os"
    disk_size_gb         = 128 #adding 64 to install pmx on C:\
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  size = "Standard_B2s"

  # source_image_reference {
  #   publisher = "MicrosoftWindowsServer"
  #   offer     = "WindowsServer"
  #   sku       = "2016-Datacenter-smalldisk"
  #   version   = "latest"
  # }

  source_image_id = data.azurerm_shared_image_version.pmx-app-image.id
  
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.environment_identity.id]
  }
  
  tags = merge(
    local.tags,
    {
      Role                 = "PMX_security_console"
      PackageName          = var.force_update_package_name == "" ? var.package_name : var.force_update_package_name
      PackageVersion       = var.force_update_package_version == "" ? var.package_version : var.force_update_package_version
      UpdateGroup          = count.index == 1 ? 1 : 2
      Alias                = local.scw_alias_tag
      ConfigStorageAccount = azurerm_storage_account.pmxapp_storageaccount.name
    }
  )
}
#                                                              #
#        END  VIRTUAL MACHINE                                  #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# #                     Data DISKS                               #
# #                                                              #

# resource "azurerm_managed_disk" "security_console" {
#   count               = var.security_console_count
#   name                = "${azurerm_windows_virtual_machine.security_console[count.index].name}-data"
#   location            = azurerm_resource_group.pmxapp_rg.location
#   resource_group_name = azurerm_resource_group.pmxapp_rg.name

#   storage_account_type = "StandardSSD_LRS"
#   create_option = "Empty"
#   disk_size_gb = 16

#   tags = merge(
#     local.common_tags
#   )
# }

# #                                                              #
# #           END Data DISKS                                     #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# #        STORAGE DISK ATTACHMENTS                              #
# #                                                              #

# resource "azurerm_virtual_machine_data_disk_attachment" "security_console" {
#   count = var.security_console_count
#   managed_disk_id = azurerm_managed_disk.security_console[count.index].id
#   virtual_machine_id = azurerm_windows_virtual_machine.security_console[count.index].id
#   lun = 0
#   caching = "ReadWrite"
# }

# #                                                              #
# #        END STORAGE DISK ATTACHMENTS                          #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           Custom Script Extension                            #
#                                                              #

# locals {
#   scw_alias_tag ="scw"
# }

# resource "azurerm_virtual_machine_extension" "security_console_cs" {
#   count                = var.security_console_count
#   name                 = "${azurerm_windows_virtual_machine.security_console[count.index].name}-cs"
#   virtual_machine_id   = azurerm_windows_virtual_machine.security_console[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   protected_settings = <<PROTECTEDSETTINGS
#   {
#     "commandToExecute": "powershell -command \"${local.attachdisk_script}\" && powershell -ExecutionPolicy Unrestricted -File attachdisk.ps1 && powershell -command \"${local.adoagent_script}\" && powershell -ExecutionPolicy Unrestricted -File az_agent_windows.ps1 ${local.scw_alias_tag} ${data.azurerm_key_vault_secret.environmentSecret.value}"
#   }
# PROTECTEDSETTINGS

#   tags = local.common_tags

#   depends_on = [
#     azurerm_virtual_machine_data_disk_attachment.security_console
#   ]
# }

# resource "azurerm_virtual_machine_extension" "security_console_cs" {
#   count                = var.security_console_count
#   name                 = "${azurerm_windows_virtual_machine.security_console[count.index].name}-cs"
#   virtual_machine_id   = azurerm_windows_virtual_machine.security_console[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   protected_settings = <<PROTECTEDSETTINGS
#   {
#     "commandToExecute": "powershell -command \"${local.configuration_script}\" && powershell -ExecutionPolicy Unrestricted -File pmx-configurator.ps1"
#   }
# PROTECTEDSETTINGS

#   tags = local.common_tags

#   depends_on = [
#     azurerm_virtual_machine_extension.security_console_jd
#   ]
# }


resource "azurerm_virtual_machine_extension" "security_console_cs" {
  count                = var.azfileshare == true ? var.security_console_count : 0
  name                 = "${azurerm_windows_virtual_machine.security_console[count.index].name}-cs"
  virtual_machine_id   = azurerm_windows_virtual_machine.security_console[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<PROTECTEDSETTINGS
  {
    "commandToExecute": "powershell -command \"${local.fs_mount_all_script};${local.fs_mount_script}\" && powershell -ExecutionPolicy Unrestricted -File fs_mount.ps1 ${data.azurerm_storage_account.pmx_fsst.primary_access_key}"
  }
PROTECTEDSETTINGS

  tags = local.common_tags
}



#                                                              #
#           END Custom Script Extension                        #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           JOIN DOMAIN                                        #
#                                                              #

resource "azurerm_virtual_machine_extension" "security_console_jd" {
  count                = var.security_console_count
  name                 = "DomainJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.security_console[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
    {
    "Name": "${var.domain.main.name}",
    "User": "${var.domain.main.user}@${var.domain.main.name}",
    "Restart": "true",
    "Options": "3"
    }
  SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#         "Password": "${var.domain.main.password}"
#     }
#   PROTECTED_SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "Password": "${data.azurerm_key_vault_secret.adds_credsecret.value}"
    }
  PROTECTED_SETTINGS

  tags = local.common_tags

  depends_on = [
    azurerm_virtual_machine_extension.security_console_cs
  ]
}

#                                                              #
#           END DOMAIN JOIN                                    #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           Security Group Attachment                          #
#                                                              #

# # Create NIC / ASG Association
# resource "azurerm_network_interface_application_security_group_association" "security_console" {
#   count = var.security_console_count
#   # network_interface_id          = module.security_console[count.index].primary_network_interface
#   network_interface_id          = azurerm_network_interface.security_console[count.index].id
#   application_security_group_id = module.security_groups.application_security_groups[local.application_security_groups.security_console]
# }

#                                                              #
#           END Security Group Attachment                      #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

