data "azuread_group" "developers" {
  display_name = "DBKI Developers"
}

data "azuread_group" "owners" {
  display_name = "DBKI Owners"
}

resource "azurerm_resource_group" "rg" {
  name     = "cs-docker-rg-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_user_assigned_identity" "docker" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = "cs-registry"
}

resource "azurerm_container_registry" "acr" {
  name                = "csdocker"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.docker.id]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(local.acr.pull)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "acr_push" {
  for_each             = toset(local.acr.push)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "acr_delete" {
  for_each             = toset(local.acr.delete)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrDelete"
  principal_id         = each.key
}
