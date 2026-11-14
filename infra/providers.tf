terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Where Terraform keeps its state: the storage account made by bootstrap/tfstate.sh
  backend "azurerm" {
    resource_group_name  = "rg-azlab-tfstate"
    storage_account_name = "stazlabtfea4a11a9"
    container_name       = "tfstate"
    key                  = "azlab.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      # On destroy, also purge the soft-deleted vault so its name is free again
      purge_soft_delete_on_destroy = true
      # On create, bring back a soft-deleted vault with the same name instead of failing
      recover_soft_deleted_key_vaults = true
    }
  }

  # We registered the resource providers ourselves in Part 0.
  resource_provider_registrations = "none"

  # The subscription comes from the ARM_SUBSCRIPTION_ID environment variable,
  # so its ID never lands in this public repo.
}
