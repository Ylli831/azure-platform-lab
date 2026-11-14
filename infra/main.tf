# Who is running Terraform: gives us the tenant, subscription and your user's object ID
data "azurerm_client_config" "current" {}

locals {
  location = "westeurope"
  prefix   = "azlab"

  # Short, stable suffix for names that must be unique across all of Azure
  suffix = substr(sha1(data.azurerm_client_config.current.subscription_id), 0, 6)

  tags = {
    project    = "azlab"
    managed_by = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = local.location
  tags     = local.tags
}
