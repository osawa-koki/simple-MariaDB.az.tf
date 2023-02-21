
variable "project_name" {
  type = string
  description = "Project name"
}

variable "mariadb_admin_username" {
  type = string
  description = "MariaDB Server administrator username."
}

variable "mariadb_admin_password" {
  type = string
  description = "MariaDB Server administrator password."
}

variable "ip_address_allowed" {
  type = string
  description = "IP address which is allowed to access to database."
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name = var.project_name
  location = "japaneast"

  tags = {
    environment = "dev"
  }
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mariadb_server
resource "azurerm_mariadb_server" "db_server" {
  name = var.project_name
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  administrator_login = var.mariadb_admin_username
  administrator_login_password = var.mariadb_admin_password

  sku_name = "B_Gen5_2"
  storage_mb = 5120
  version = "10.2"

  auto_grow_enabled = true
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled = true
  ssl_enforcement_enabled = false
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mariadb_database
resource "azurerm_mariadb_database" "db_database" {
  name = var.project_name
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name = azurerm_mariadb_server.db_server.name
  charset = "utf8mb4"
  collation = "utf8mb4_unicode_520_ci"
}

resource "azurerm_mariadb_firewall_rule" "firewall" {
  name = var.project_name
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name = azurerm_mariadb_server.db_server.name
  start_ip_address = var.ip_address_allowed
  end_ip_address = var.ip_address_allowed
}

// 接続文字列をファイルに出力
output "connection_string" {
  value = "Server=${azurerm_mariadb_server.db_server.name}.mariadb.database.azure.com;Database=${azurerm_mariadb_database.db_database.name};User Id=${var.mariadb_admin_username};Password=${var.mariadb_admin_password}"
}
