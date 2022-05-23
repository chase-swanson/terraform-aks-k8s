resource "azurerm_user_assigned_identity" "helm" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = "cs-helm-registry"
}

resource "azurerm_container_registry" "helm_acr" {
  name                = "cshelm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.helm.id]
  }
}

resource "azurerm_role_assignment" "helm_acr_pull" {
  for_each             = toset(local.acr.pull)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "helm_acr_push" {
  for_each             = toset(local.acr.push)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "helm_acr_delete" {
  for_each             = toset(local.acr.delete)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrDelete"
  principal_id         = each.key
}
