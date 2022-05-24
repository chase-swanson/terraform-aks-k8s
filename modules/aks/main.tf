
resource "azurerm_resource_group" "rg" {
  name     = "cs-k8s-rg-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cs-vnet-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.192.0.0/12"]

  subnet {
    address_prefix = "10.192.0.0/21"
    name           = "k8s-sys-subnet-${var.environment}"
  }
  subnet {
    address_prefix = "10.192.8.0/21"
    name           = "k8s-usr-subnet-${var.environment}"
  }
  subnet {
    address_prefix = "10.193.0.0/16"
    name           = "app-gw-subnet-${var.environment}"
  }
  tags = var.tags
}


data "azurerm_subnet" "sys_subnet" {
  name                 = "k8s-sys-subnet-${var.environment}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}


data "azurerm_subnet" "usr_subnet" {
  name                 = "k8s-usr-subnet-${var.environment}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "gw_subnet" {
  name                 = "app-gw-subnet-${var.environment}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                      = "cs-k8s-${var.environment}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  tags                      = var.tags
  dns_prefix                = "cs-k8s-${var.environment}"
  kubernetes_version        = "1.23.5"
  node_resource_group       = "cs-k8s-node-rg-${var.environment}"
  automatic_channel_upgrade = "patch"
  azure_policy_enabled      = "true"
  open_service_mesh_enabled = true

  # private_cluster_enabled   = true

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }

  default_node_pool {
    name                = "agentpool"
    vm_size             = "standard_d2s_v5"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    vnet_subnet_id      = data.azurerm_subnet.sys_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  ingress_application_gateway {
    gateway_name = "app-gateway-${var.environment}"
    subnet_id    = data.azurerm_subnet.gw_subnet.id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "standard_d2s_v5"
  node_count            = 1
  mode                  = "User"
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 5
  vnet_subnet_id        = data.azurerm_subnet.usr_subnet.id

}


resource "azurerm_role_assignment" "cluster_admins" {
  principal_id         = "fa48efab-4ce2-4c75-bf1d-542a4355b427"
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.k8s.id
}
