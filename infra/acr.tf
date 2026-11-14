resource "azurerm_container_registry" "main" {
  name                = "acr${local.prefix}${local.suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Basic: cheapest tier (flat daily fee). Premium adds private endpoints and geo-replication.
  sku = "Basic"

  # No shared username/password. People and services sign in with their own Entra ID identity.
  admin_enabled = false

  tags = local.tags
}
