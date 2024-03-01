
resource "random_id" "core-sus" {
  count       = var.pmx_core == true ? var.core_sus_count : 0
  byte_length = 3
}



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        VIRTUAL MACHINE                                       #
#                                                              #

resource "azurerm_windows_virtual_machine" "core-sus" {
  count = var.pmx_core == true ? var.core_sus_count : 0
  name                = "${var.datacenter}${random_id.core-sus[count.index].hex}"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  size                = "Standard_D2s_v4"

  network_interface_ids = [
      azurerm_network_interface.core-sus[count.index].id
    ]

  computer_name = replace("${var.datacenter}${random_id.core-sus[count.index].hex}", "/[_\\-]/", "")

  availability_set_id = azurerm_availability_set.pmx_core-sus.id

  admin_username = var.admin_username
  admin_password = data.azurerm_key_vault_secret.pmx_syscredsecret.value

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-smalldisk"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.datacenter}${random_id.core-sus[count.index].hex}-os"
    disk_size_gb         = 64
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  tags = merge(
    local.tags,
    {
      Role        = "PMX_Search_Update_Services"
      UpdateGroup = count.index == 1 ? 1 : 2
    }
  )
}
#                                                              #
#        END  VIRTUAL MACHINE                                  #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                     Data DISKS                               #
#                                                              #

resource "azurerm_managed_disk" "core-sus" {
  count               = var.pmx_core == true ? var.core_sus_count : 0
  name                = "${azurerm_windows_virtual_machine.core-sus[count.index].name}-data"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  storage_account_type = "StandardSSD_LRS"
  create_option = "Empty"
  disk_size_gb = 16

  tags = merge(
    local.common_tags
  )
}

#                                                              #
#           END Data DISKS                                     #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        STORAGE DISK ATTACHMENTS                              #
#                                                              #

resource "azurerm_virtual_machine_data_disk_attachment" "core-sus" {
  count = var.pmx_core == true ? var.core_sus_count : 0
  managed_disk_id = azurerm_managed_disk.core-sus[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.core-sus[count.index].id
  lun = 0
  caching = "ReadWrite"
}

#                                                              #
#        END STORAGE DISK ATTACHMENTS                          #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# #           Custom Script Extension                            #
# #                                                              #

# locals {
#   sus_alias_tag ="sus"
# }

# resource "azurerm_virtual_machine_extension" "sus_cs" {
#   count                = var.pmx_core == true ? var.core_sus_count : 0
#   name                 = "${azurerm_windows_virtual_machine.core-sus[count.index].name}-cs"
#   virtual_machine_id   = azurerm_windows_virtual_machine.core-sus[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   protected_settings = <<PROTECTEDSETTINGS
#   {
#     "commandToExecute": "powershell -command \"${local.attachdisk_script}\" && powershell -ExecutionPolicy Unrestricted -File attachdisk.ps1 && powershell -command \"${local.adoagent_script}\" && powershell -ExecutionPolicy Unrestricted -File az_agent_windows.ps1 ${local.sus_alias_tag} ${data.azurerm_key_vault_secret.environmentSecret.value}"
#   }
# PROTECTEDSETTINGS

#   tags = local.common_tags

#   depends_on = [
#     azurerm_virtual_machine_data_disk_attachment.core-sus
#   ]

# }

# #                                                              #
# #           END Custom Script Extension                        #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           JOIN DOMAIN                                        #
#                                                              #

resource "azurerm_virtual_machine_extension" "core-sus-jd" {
  count                = var.pmx_core == true ? var.core_sus_count : 0
  name                 = "DomainJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.core-sus[count.index].id
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

  # depends_on = [
  #   azurerm_virtual_machine_extension.sus_cs
  # ]
}

#                                                              #
#           END DOMAIN JOIN                                    #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#           Security Group Attachment                          #
#                                                              #

# # Create NIC / ASG Association
# resource "azurerm_network_interface_application_security_group_association" "core-sus" {
#   count = var.pmx_core == true ? var.core_sus_count : 0
#   network_interface_id          = azurerm_network_interface.core-sus[count.index].id
#   application_security_group_id = module.security_groups.application_security_groups[local.core_application_security_groups.sus]
# }

#                                                              #
#           END Security Group Attachment                      #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

