terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
#   tenant_id       = var.tf_provider_azurerm_tenant_id
#   subscription_id = var.tf_provider_azurerm_prod_cloud_sub_id
#   client_id       = var.tf_provider_azurerm_prod_cloud_build_client_id
#   client_secret   = var.tf_provider_azurerm_prod_cloud_build_client_secret
}

# provider "azurerm" {
#   features {}
#   alias           = "adds-credentials-subscription"
#   subscription_id = var.domain.main.domain_password_subscription
# }

provider "azurerm" {
  features {}
  alias           = "azure-imageGallery-subscription"
  subscription_id = var.azure_imageGallery_subscription
}

provider "azurerm" {
  features {}
  alias           = "central-hub-subscription"
  subscription_id = var.network.central_hub_subscription
}

provider "azurerm" {
  features {}
  alias           = "pmxservices-dnszone-subscription"
  subscription_id = var.pmxservices_dns.dnszone_provider_subscription
}

provider "azuredevops" {
  org_service_url       = var.orgurl
  personal_access_token = var.pat
}

provider "azapi" {
}

# provider "azurerm" {
#   skip_provider_registration = true
#   features {}
#   alias           = "globalResources_subscription"
#   subscription_id = var.globalResources_subscription
#   client_id       = var.qa_build_client_id
#   client_secret   = var.qa_build_client_secret
# }

# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# #     SERVICE PRINCIPAL                                        #
# #                                                              #

# provider "azurerm" {
#   alias = "sub-central-connectivity"
#   features {}
#   tenant_id       = var.tf_provider_azurerm_tenant_id
#   subscription_id = var.tf_provider_azurerm_central_connectivity_sub_id
#   client_id       = var.tf_provider_azurerm_central_connectivity_build_client_id
#   client_secret   = var.tf_provider_azurerm_central_connectivity_build_client_secret
# }

# #                                                              #
# #     END SERVICE PRINCIPAL                                    #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#     SERVICE PRINCIPAL                                        #
#                                                              #

/* provider "azurerm" {
  alias = "sub-central-identity"
  features {}
  tenant_id       = var.tf_provider_azurerm_tenant_id
  subscription_id = var.tf_provider_azurerm_central_identity_sub_id
  client_id       = var.tf_provider_azurerm_central_identity_build_client_id
  client_secret   = var.tf_provider_azurerm_central_identity_build_client_secret
} */

#                                                              #
#     END SERVICE PRINCIPAL                                    #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#     SERVICE PRINCIPAL                                        #
#                                                              #

# provider "azurerm" {
#   alias = "sub-central-management"
#   features {}
#   tenant_id       = var.tf_provider_azurerm_tenant_id
#   subscription_id = var.tf_provider_azurerm_central_management_sub_id
#   client_id       = var.tf_provider_azurerm_central_management_build_client_id
#   client_secret   = var.tf_provider_azurerm_central_management_build_client_secret
# }

#                                                              #
#     END SERVICE PRINCIPAL                                    #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
