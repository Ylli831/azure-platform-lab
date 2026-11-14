resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Pay per GB of data sent in
  sku = "PerGB2018"

  # 30 days of retention is included in the ingestion price
  retention_in_days = 30

  # Stop collecting for the day after 0.5 GB, so a chatty cluster can't burn the credit.
  # In production you'd alert on ingestion instead: a cap silently drops logs.
  daily_quota_gb = 0.5

  tags = local.tags
}
