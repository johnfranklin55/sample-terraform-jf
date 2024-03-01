terraform {
  required_version = ">= 0.14"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.0, >= 3.24.0"
    #   configuration_aliases = [azurerm.sub-central-connectivity]
    }
    
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "0.2.2"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "0.4.0"
    }
  }

  # Want to include optional vars
  #
  experiments = [module_variable_optional_attrs]
}
