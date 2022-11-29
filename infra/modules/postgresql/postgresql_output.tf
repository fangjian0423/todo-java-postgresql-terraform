output "AZURE_POSTGRESQL_DATABASE_NAME" {
  value     = azurerm_postgresql_database.database.name
  sensitive = true
}

output "AZURE_POSTGRESQL_FQDN" {
  value = azurerm_postgresql_server.psqlServer.fqdn
}

output "AZURE_POSTGRESQL_USERNAME" {
  value = azurerm_postgresql_active_directory_administrator.psql_aad_admin.login
}

output "AZURE_POSTGRESQL_SERVER_NAME" {
  value = azurerm_postgresql_server.psqlServer.name
}