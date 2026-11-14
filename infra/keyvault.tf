resource "azurerm_key_vault" "main" {
  name                = "kv-${local.prefix}-${local.suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Access is controlled with Azure roles, not the older per-vault access policies
  rbac_authorization_enabled = true

  # Lab settings: shortest soft-delete window, no purge protection, so teardown is clean.
  # In production: purge protection on, longer retention, private endpoint.
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = local.tags
}

# Owner manages the vault but can't read its secrets. This role lets you manage secrets.
resource "azurerm_role_assignment" "kv_secrets_officer_me" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}
