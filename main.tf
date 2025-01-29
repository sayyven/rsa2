terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}


provider "azurerm" {
  subscription_id = "b98a4ecc-db16-46cc-9fdd-d725310cda6a"



/*  subscription_id = "b98a4ecc-db16-46cc-9fdd-d725310cda6a"
  tenant_id = "f3eecbb4-2c11-4444-9d12-620a608677ef"
  client_id = "16d7d637-04c7-414d-ae3b-1c9dce09e551"
  client_secret = "Qj38Q~QGWwpkZy1iiZG3s5lDa83XCUI6QaEMcbEc" */
  features {}
}

