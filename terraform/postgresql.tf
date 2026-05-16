# Azure Database for PostgreSQL
resource "azurerm_postgresql_server" "postgres" {
  name                = "${replace(var.project_name, "-", "")}db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = var.postgres_admin_user
  administrator_login_password = var.postgres_admin_password

  sku_name   = var.postgres_sku
  version    = var.postgres_version
  storage_mb = var.postgres_storage_mb

  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  auto_grow_enabled                 = true
  infrastructure_encryption_enabled = false

  tags = local.common_tags
}

# Firewall rule para permitir Azure Services
resource "azurerm_postgresql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgres.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Database
resource "azurerm_postgresql_database" "kubenews_db" {
  name                = var.postgres_database_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgres.name
  charset             = "UTF8"
  collation           = "en_US.utf8"
}

# Output para usar no Kubernetes
output "postgres_fqdn" {
  value       = azurerm_postgresql_server.postgres.fqdn
  description = "PostgreSQL FQDN"
}

output "postgres_password" {
  value       = azurerm_postgresql_server.postgres.administrator_login_password
  sensitive   = true
  description = "PostgreSQL admin password"
}
