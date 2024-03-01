# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#               Authorization                                  #
#                                                              #

variable "service_principlal" {
  description = "Automation service principal display name"
  type        = string
}

#                                                              #
#               END Authorization                              #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        VIRTUAL MACHINE IDENTITY VARIABLES                    #
#                                                              #

variable "domain" {
  description = "A map of domain objects containing a name, and an account with which to join computers to that domain."
  type = map(
    object({
      name                            = string
      user                            = string
      # password                        = string
      # domain_password_subscription    = string
      # domain_password_resourcegroup   = string
      # domain_password_keyvault        = string
      domain_password_secret          = string
      dns_servers                     = list(string)
    })
  )
  sensitive = true
}

#                                                              #
#        END VIRTUAL MACHINE IDENTITY VARIABLES                #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#     BUILD IDENTITY VARIABLES                                 #
#                                                              #

variable "tf_provider_azurerm_tenant_id" {
  type        = string
  description = "Tenant ID"
  default     = ""
}

variable "tf_provider_azurerm_prod_cloud_sub_id" {
  type        = string
  description = "Subscription ID"
  default     = ""
}

variable "tf_provider_azurerm_prod_cloud_build_client_id" {
  type        = string
  description = "Build Client ID"
  default     = ""
}

variable "tf_provider_azurerm_prod_cloud_build_client_secret" {
  type        = string
  description = "Build Client Secret"
  sensitive   = true
  default     = ""
}

#                                                              #
#     END BUILD IDENTITY VARIABLES                             #
# # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        DATACENTER VARIABLES                                  #
#                                                              #

variable "datacenter" {
  type = string
}

variable "environment" {
  type = string
}

variable "LongEnvironmentName" {
  type = string
}

variable "location" {
  type = string
}

#                                                              #
#        END DATACENTER VARIABLES                              #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        APPLICATION INSTANCE VARIABLES                        #
#                                                              #

variable "pmx_core" {
  type        = bool
  description = "Is this a PMX Core environment? True - Core, False - Flex"
}

variable "identifier" {
  type        = string
  description = "An identifier for the environment (ie. application version, flex customer, etc.)."

  validation {
    error_message = "Input 'var.identifier' may not contain spaces or dashes, and must match '^[0-9A-Za-z_]+$'."
    condition     = can(regex("^[[:word:]]+$", var.identifier))
  }
}

variable "tags" {
  type        = map(string)
  description = "Azure tags for the PMX resources"
  default     = {}
}

#                                                              #
#        END APPLICATION INSTANCE VARIABLES                    #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        NETWORK VARIABLES                                     #
#                                                              #

variable "network" {
  type = object({
    netsec_name                               = string
    netsec_resourcegroup                      = string
    egress_gateway_address                    = optional(string)

    adds_virtual_network_address_space        = list(string)
    adds_subnet_address_space                 = list(string)

    paas_virtual_network_address_space        = list(string)
    paas_subnet_address_space                 = list(string)

    fileshare_virtual_network_address_space   = list(string)
    fileshare_subnet_address_space            = list(string)

    app_virtual_network_address_space         = list(string)
    app_subnet_address_space                  = list(string)

    pmxservices_virtual_network_address_space = list(string)
    pmxservices_subnet_address_space          = list(string)

    dns_servers                               = optional(list(string))

    central_hub_connectivity  = bool
    central_hub_subscription  = optional(string)
    central_hub_name          = optional(string)
    central_hub_resourcegroup = optional(string)
  })
  description = "Object representing network configuration for PMX"
}

variable "network_security_group_rules" {
  type = list(
    object({
      file = string
      data = optional(map(any))
    })
  )
  description = "Optional Additional NSG rules"
  default     = []
}

#                                                              #
#        END NETWORK VARIABLES                                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#     APPLICATION SECURITY GROUP VARIABLES                     #
#                                                              #

#                                                              #
#     END APPLICATION SECURITY GROUP VARIABLES                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#     NETWORK SECURITY GROUP VARIABLES                         #
#                                                              #



#                                                              #
#     END NETWORK SECURITY GROUP VARIABLES                     #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        ENVIRONMENT CONFIGURATION VARIABLES                   #
#                                                              #

variable "admin_username" {
  type      = string
  sensitive = true
}

variable "admin_password_secret" {
  type      = string
  sensitive = true
}

#                                                              #
#        END ENVIRONMENT CONFIGURATION VARIABLES               #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++ #
#          Environment variables          #
#                                         #

variable "environment_resourcegroup" {
  type      = string
  sensitive = true
  description = "Resource Group of the PMX Environment (Landing Zone:sandbox/qa/prod)"  
}

#                                         #
#         END Environment variables       #
# +++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++ #
#           Syscred Keyvault              #
#                                         #

variable "syscredKeyvault_name" {
  type      = string
  sensitive = true
  description = "Keyvault that contains system credential secrets"  
}

# variable "syscredKeyvault_resourcegroup" {
#   type      = string
#   sensitive = true
#   description = "Resource Group of the Keyvault that contains system credential secrets"  
# }

#                                         #
#          END Syscred Keyvault           #
# +++++++++++++++++++++++++++++++++++++++ #


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        APPLICAITON SIZING CONFIGURATION VARIABLES            #
#                                                              #


# App/Web/Api servers
#
variable "primary_app_count" {
  type        = number
  description = "Number of PMX Primary Application servers"
  default     = 1
}

variable "secondary_app_count" {
  type        = number
  description = "Number of PMX Secondary Application servers"
}

variable "web_count" {
  type        = number
  description = "Number of PMX web servers"
}

variable "api_count" {
  type        = number
  description = "Number of PMX API servers"
}

# Windows/Security/SUS servers
#
variable "windows_count" {
  type        = number
  description = "Number of PMX Windows servers"
}

variable "security_console_count" {
  type        = number
  description = "Number of PMX Security Console servers"
  default     = 2
}

variable "core_sus_count" {
  type        = number
  description = "Number of PMX SUS (Security Update Services) servers"
  default     = 0
}

#                                                              #
#        END APPLICAITON SIZING CONFIGURATION VARIABLES        #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#        Azure Devops Automation Configuration                 #
#                                                              #

variable "orgurl" {
  type      = string
  sensitive = true
}

variable "pat" {
  type      = string
  sensitive = true
}

#                                                              #
#        END Azure Devops Automation Configuration             #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                      VM Image Variables                      #
#                                                              #

variable "azure_imageGallery_subscription" {
  type      = string
}

variable "package_name" {
  type      = string
}

variable "package_version" {
  type      = string
}

variable "single_image" {
  type      = bool
}

variable "force_update_package_name" {
  type        = string
  default     = ""
  description = "Optional value to install a version that is different than the base image"
}

variable "force_update_package_version" {
  type        = string
  default     = ""
  description = "Optional value to install a version that is different than the base image"
}

#                                                              #
#                       END VM Image Variables                 #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                Configuration Table Variables                 #
#                                                              #

variable "config" {
  type = object({
    cleanup               = string
    loglevel              = string
    configrun             = string
    serviceRegistration   = string
    SSLConfig             = string
  })
  description = "Configuration Control settings"
  default = {
    cleanup               = "true"
    loglevel              = "DEBUG"
    configrun             = "true"
    serviceRegistration   = "true"
    SSLConfig             = "true"
  }
}

variable "config_environment_keyvault_name" {
  type      = string
}

# variable "config_environment_keyvault_resourcegroup" {
#   type      = string
# }

variable "db_admin_username" {
  type      = string
}

variable "db_admin_password_secret" {
  type      = string
}

variable "pmx_domain_service_user" {
  type      = string
}

variable "pmx_domain_service_secret" {
  type      = string
}

#                                                              #
#              END Configuration Table Variables               #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                    Azure Files variables                     #
#                                                              #

variable "azfileshare" {
  type      = bool
}

variable "azfileshare_storage_random_id" {
  type      = string
}

#                                                              #
#                  END Azure Files variables                   #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                        PaaS variables                        #
#                                                              #

variable "paas" {
  type = object({
    sqlmi = object({
      name                  = string
      resourceGroup         = string
    })
  })
  description = "PMX PaaS Variables"
}

#                                                              #
#                      END PaaS variables                      #
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++ #
#         Managed Identity                #
#                                         #

variable "environment_foundation_identity_name" {
  type      = string
}

# variable "environment_foundation_identity_resourceGroup" {
#   type      = string
# }

#                                         #
#       END Managed Identity              #
# +++++++++++++++++++++++++++++++++++++++ #


# +++++++++++++++++++++++++++++++++++++++ #
#           AppGateway Variables          #
#                                         #

variable "pmx_appgw_muid" {
  type = object({
    name            = string
  })
  description = "PMX Appgateway managed user assigned identity"
}

variable "pmx_cert" {
  type = object({
    keyvault_name           = string
    certificate_name        = string
  })
  description = "PMX Wild card certificate variables"
}

#                                         #
#           END AppGateway Variables      #
# +++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++ #
#       External DNS and Certficate       #
#                                         #

variable "external_subdomain" {
  type      = string
}

variable "external_root_domain" {
  type      = string
}


# variable "globalResources_subscription" {
#   type      = string
# }

# variable "connectivity_ResourceGroup" {
#   type      = string
# }

variable "qa_build_client_id" {
  type      = string
  default = ""
}

variable "qa_build_client_secret" {
  type      = string
  default = ""
}

#                                         #
#     END External DNS and Certficate     #
# +++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++ #
#              PMX Services               #
#                                         #

  variable "pmxservices" {
  type        = bool
  description = "pmxservices Deployment"
  default     = true
}

#                                         #
#            END PMX Services             #
# +++++++++++++++++++++++++++++++++++++++ #

# +++++++++++++++++++++++++++++++++++++++ #
#              Platform X                 #
#                                         #

variable "platform_x" {
  type        = bool
  description = "Platform X Deployment"
  default     = false
}

#                                         #
#            END Platform X               #
# +++++++++++++++++++++++++++++++++++++++ #