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
# Deploy app service web app
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "web_name" {
  name          = "${var.service_name}-${var.resource_token}"
  resource_type = "azurerm_app_service"
  random_length = 0
  clean_input   = true
}

resource "azurerm_linux_web_app" "web" {
  name                = azurecaf_name.web_name.result
  location            = var.location
  resource_group_name = var.rg_name
  service_plan_id     = var.appservice_plan_id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on        = true
    ftps_state       = "FtpsOnly"
    app_command_line = var.app_command_line
    application_stack {
      java_version = var.java_version
      java_server = "JAVA"
    }
  }

  app_settings = var.app_settings

  dynamic "identity" {
    for_each = { for k, v in var.identity : k => v if var.identity != [] }
    content {
      type = identity.value["type"]
    }
  }

  logs {
    application_logs {
      file_system_level = "Verbose"
    }
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }
}

resource "azurecaf_name" "app_umi" {
  resource_type       = "azurerm_user_assigned_identity"
  name                = "pqsl-script"

  provisioner "local-exec" {
#    command     = "./scripts/psql-create-db-aad-user-flexible-server.sh ${var.database_fqdn} ${azurerm_linux_web_app.web.identity.0.principal_id} ${var.database_name} ${var.database_username}"
    command     = "./scripts/psql-create-db-aad-user-single-server.sh ${var.database_fqdn} ${azurerm_linux_web_app.web.identity.0.principal_id} ${var.database_name} ${var.database_username} ${var.database_server_name}"
    working_dir = path.module
    when        = create
  }
}