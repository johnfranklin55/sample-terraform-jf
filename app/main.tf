
locals {
  tags = merge(
    {
      Domain                 = var.domain.main.name
      WorkloadName           = "PMX"
      Datacenter             = var.datacenter
      Environment            = var.environment
      LongEnvironmentName    = var.LongEnvironmentName
      WorkloadName           = "PMX_X5_Core"
    },
    var.tags
  )
}

locals {
  availability_sets = {
    api              = "avs-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-api"
    secondary_app    = "avs-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-secondary_app"
    web              = "avs-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-web"
    security_console = "avs-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-security_console"
    windows          = "avs-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-windows"
  }

  core_availability_sets = {
    sus = "avs-${var.datacenter}-${var.environment}-pmx_core_${var.identifier}-sus"
  }
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#       Custom Script Extension data and locals                #
#                                                              #

# data "azurerm_key_vault" "pmxapp_cse_kv" {
#   name                = var.devopsautomation.keyvault.name
#   resource_group_name = var.devopsautomation.keyvault.resource_group_name
# }

# data "azurerm_key_vault_secret" "pmxapp_cse_secret" {
#   name         = var.devopsautomation.keyvault.key
#   key_vault_id = data.azurerm_key_vault.pmxapp_cse_kv.id
# }

# data "template_file" "attach-disk-tf" {
#   template = "${file("./scripts/attachdisk.ps1")}"
# } 

# locals {
#   attachdisk_script = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.attach-disk-tf.rendered)}')) | Out-File -filepath attachdisk.ps1"
# }

# data "template_file" "configuration_tf" {
#   template = "${file("./scripts/pmx-configurator.ps1")}"
# } 

# locals {
#   configuration_script = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.configuration_tf.rendered)}')) | Out-File -filepath pmx-configurator.ps1"
# }



data "template_file" "fs_mount_tf" {
  template = templatefile("./scripts/fs_mount.ps1",
    {
      pmx_fileshare_storage = "stpmx%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}${var.datacenter}${var.azfileshare_storage_random_id}",
      pmx_fileshare_record  = "${var.datacenter}-${var.environment}-pmxfileshare",
      pmx_fileshare         = "fs-${var.datacenter}-${var.environment}-pmx-%{if var.pmx_core}core%{else}flex%{endif}-${var.identifier}",
    }
  )
}

data "azurerm_storage_account" "pmx_fsst" {
  name                = "stpmx%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}${var.datacenter}${var.azfileshare_storage_random_id}"
  resource_group_name = "rg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-fileshare"
}


locals {
  fs_mount_script = "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.fs_mount_tf.rendered)}')) | Out-File -filepath fs_mount.ps1"
}


data "template_file" "fs_mount_all_tf" {
  template = templatefile("./scripts/fs_mount_all.ps1",
    {
      pmx_fileshare_storage = "stpmx%{if var.pmx_core}core%{else}flex%{endif}${var.identifier}${var.datacenter}${var.azfileshare_storage_random_id}",
      pmx_fileshare_record  = "${var.datacenter}-${var.environment}-pmxfileshare",
      pmx_fileshare         = "fs-${var.datacenter}-${var.environment}-pmx-%{if var.pmx_core}core%{else}flex%{endif}-${var.identifier}",
      pmx_fileshare_rg      = data.azurerm_storage_account.pmx_fsst.resource_group_name
    }
  )
}

locals {
  fs_mount_all_script = "New-Item 'C:/scripts' -itemType Directory ;[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.fs_mount_all_tf.rendered)}')) | Out-File -filepath C:/scripts/fs_mount_all.ps1"
}


#                                                              #
#     END Custom Script Extension data and locals              #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++++++++++ #
#      RESOURCE GROUP                             #
#                                                 #

resource "azurerm_resource_group" "pmxapp_rg" {
  name     = "rg-${var.datacenter}-${var.environment}-pmx_%{if var.pmx_core}core%{else}flex%{endif}_${var.identifier}-app"
  location = var.location

  tags = local.tags
}

#                                                 #
#      END RESOURCE GROUP                         #
# +++++++++++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++++++++++ #
#              Images                             #
#                                                 #

data "azurerm_shared_image_version" "pmx-web-image" {
  provider            = azurerm.azure-imageGallery-subscription
  name                = var.package_version
  image_name          = var.single_image == true ? "pmx-single-image-${var.package_name}" : "pmx-single-image-${var.package_name}"
  gallery_name        = "pmxImageGallery"
  resource_group_name = "rg-ue01-qa-pmx_core_x5-aib"
}

data "azurerm_shared_image_version" "pmx-windows-image" {
  provider            = azurerm.azure-imageGallery-subscription
  name                = var.package_version
  image_name          = var.single_image == true ? "pmx-single-image-${var.package_name}" : "pmx-windows-image-${var.package_name}"
  gallery_name        = "pmxImageGallery"
  resource_group_name = "rg-ue01-qa-pmx_core_x5-aib"
}

data "azurerm_shared_image_version" "pmx-app-image" {
  provider            = azurerm.azure-imageGallery-subscription
  name                = var.package_version
  image_name          = var.single_image == true ? "pmx-single-image-${var.package_name}" : "pmx-app-image-${var.package_name}"
  gallery_name        = "pmxImageGallery"
  resource_group_name = "rg-ue01-qa-pmx_core_x5-aib"
}

#                                                 #
#              END Images                         #
# +++++++++++++++++++++++++++++++++++++++++++++++ #


# +++++++++++++++++++++++++++++++++++++++++++++++ #
#             Constant VM Data                    #
#                                                 #
locals {
  api_alias_tag ="api"
}

resource "random_id" "api" {
  count       = var.api_count
  byte_length = 1
}

locals {
  pa_alias_tag ="pa"
}

resource "random_id" "primary_app" {
  count       = var.primary_app_count
  byte_length = 1
}

locals {
  sa_alias_tag ="sa"
}

resource "random_id" "secondary_app" {
  count       = var.secondary_app_count
  byte_length = 1
}

locals {
  scw_alias_tag ="scw"
}

resource "random_id" "security_console" {
  count       = var.security_console_count
  byte_length = 1
}

locals {
  ws_alias_tag ="ws"
}

resource "random_id" "web" {
  count       = var.web_count
  byte_length = 1
}

locals {
  wim_alias_tag ="wim"
}

resource "random_id" "wim" {
  byte_length = 1
}

locals {
  wi_alias_tag ="wi"
}

resource "random_id" "windows" {
  count       = var.windows_count
  byte_length = 1
}

#                                                 #
#             END Constant VM Data                #
# +++++++++++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++++++++++ #
#                 VM credentials                  #
#                                                 #

data "azurerm_key_vault" "pmx_syscredkv" {
  name                = var.syscredKeyvault_name
  # resource_group_name = var.syscredKeyvault_resourcegroup
  resource_group_name = var.environment_resourcegroup
}


data "azurerm_key_vault_secret" "pmx_syscredsecret" {
  name         = var.admin_password_secret
  key_vault_id = data.azurerm_key_vault.adds_credkv.id
}

#                                                 #
#                 END VM credentials              #
# +++++++++++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++++++++++ #
#                 Data Sources                    #
#                                                 #

### database data
data "azurerm_mssql_managed_instance" "pmx_sqlmi" {
  name                = var.paas.sqlmi.name
  resource_group_name = var.paas.sqlmi.resourceGroup
}

### domain cred data
data "azurerm_key_vault" "adds_credkv" {
  name                = var.syscredKeyvault_name
  # resource_group_name = var.syscredKeyvault_resourcegroup
  resource_group_name = var.environment_resourcegroup
}

data "azurerm_key_vault_secret" "adds_credsecret" {
  name         = var.domain.main.domain_password_secret
  key_vault_id = data.azurerm_key_vault.adds_credkv.id
}


# data "azurerm_key_vault" "adds_credkv" {
#   provider            = azurerm.adds-credentials-subscription
#   name                = var.domain.main.domain_password_keyvault
#   resource_group_name = var.domain.main.domain_password_resourcegroup
# }


# data "azurerm_key_vault_secret" "adds_credsecret" {
#   provider     = azurerm.adds-credentials-subscription
#   name         = var.domain.main.domain_password_secret
#   key_vault_id = data.azurerm_key_vault.adds_credkv.id
# }

#                                                 #
#                 END Data Sources                #
# +++++++++++++++++++++++++++++++++++++++++++++++ #
