data "azuread_group" "owners" {
  display_name = "DBKI Owners"
}
resource "azurerm_resource_group" "rg" {
  name     = "cs-k8s-rg-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "cs-k8s-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  dns_prefix          = "cs-k8s-${var.environment}"
  kubernetes_version  = "1.23.5"
  node_resource_group = "cs-k8s-node-rg-${var.environment}"
  # private_cluster_enabled   = true
  open_service_mesh_enabled = true
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  network_profile {
    network_plugin = "kubenet"
    # network_policy = "calico"
  }

  default_node_pool {
    name                = "default"
    vm_size             = "standard_d4s_v5"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}

resource "azurerm_role_assignment" "acr_role" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.docker_registry_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "cluster_admins" {
  principal_id         = data.azuread_group.owners.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.k8s.id
}