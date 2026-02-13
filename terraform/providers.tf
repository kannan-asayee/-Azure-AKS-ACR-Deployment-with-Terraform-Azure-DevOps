terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Values passed via pipeline
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
