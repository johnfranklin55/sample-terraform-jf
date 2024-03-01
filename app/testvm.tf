

data "azurerm_shared_image_version" "pmx-test-image" {
  name                = "10.6.7223"
  image_name          = "pmx-single-image-trunk"
  gallery_name        = "pmxImageGallery"
  resource_group_name = "rg-ue01-qa-pmx_core_x5-aib"
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK INTERFACE                                     #
#                                                              #

resource "azurerm_network_interface" "vm_mgmt-test" {
  name                = "nic-${var.datacenter}${var.environment}-pmx-mgmt-test"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name

  ip_configuration {
    name                          = "ipconfig-0-nic-${var.datacenter}${var.environment}-pmx-mgmt-test"
    subnet_id                     = azurerm_subnet.pmxapp_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}
#                                                              #
#        END NETWORK INTERFACE                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        VIRTUAL MACHINE                                       #
#                                                              #

resource "azurerm_windows_virtual_machine" "vm_mgmt-test" {
  name                = "${var.datacenter}${var.environment}-pmx-testvm"
  location            = azurerm_resource_group.pmxapp_rg.location
  resource_group_name = azurerm_resource_group.pmxapp_rg.name
  size                = "Standard_B2s"

  network_interface_ids = [
      azurerm_network_interface.vm_mgmt-test.id
    ]

  computer_name = "testvm"


  admin_username = var.admin_username
  admin_password = data.azurerm_key_vault_secret.pmx_syscredsecret.value

  source_image_id = data.azurerm_shared_image_version.pmx-test-image.id

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.environment_identity.id]
  }

  os_disk {
    name                 = "${var.datacenter}${var.environment}-pmx-mgmt-test-os"
    disk_size_gb         = 128
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  tags = merge(
    local.tags,
    {
      Role        = "PMX_MGMT-test_VM"
      UpdateGroup = 2
    }
  )
}

#                                                              #
#        END  VIRTUAL MACHINE                                  #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# #                                                              #
# #           END Custom Script Extension                        #

# resource "azurerm_virtual_machine_extension" "test_cs" {
#   name                 = "${azurerm_windows_virtual_machine.vm_mgmt-test.name}-cs"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm_mgmt-test.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   protected_settings = <<PROTECTEDSETTINGS
#   {
#     "commandToExecute": "powershell -command \"New-Item 'C:/scripts' -itemType Directory ;${local.fs_mount_all_script}\""
#   }
# PROTECTEDSETTINGS

#   tags = local.common_tags
# }

# #                                                              #
# #           END Custom Script Extension                        #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #