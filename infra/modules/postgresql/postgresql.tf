terraform {
  required_providers {
    azurerm = {
      version = "~>3.33.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.15"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy cosmos db account
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "db_acc_name" {
  name          = var.resource_token
  resource_type = "azurerm_cosmosdb_account"
  random_length = 0
  clean_input   = true
}

data "azurerm_client_config" "current" {}

data "azuread_user" "current_user" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_postgresql_server" "psqlServer" {
  name                            = azurecaf_name.db_acc_name.result
  location                        = var.location
  resource_group_name             = var.rg_name

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

}


resource "azurerm_postgresql_firewall_rule" "firewall_rule" {
  name                            = "AllowAllFireWallRule"
  resource_group_name = var.rg_name
  server_name         = azurerm_postgresql_server.psqlServer.name
  start_ip_address                = "0.0.0.0"
  end_ip_address                  = "255.255.255.255"
}

resource "azurerm_postgresql_database" "database" {
  name      = "todo"
  resource_group_name = var.rg_name
  server_name         = azurerm_postgresql_server.psqlServer.name
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_active_directory_administrator" "psql_aad_admin" {
  server_name         = azurerm_postgresql_server.psqlServer.name
  resource_group_name = var.rg_name
  login               = data.azuread_user.current_user.user_principal_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}
