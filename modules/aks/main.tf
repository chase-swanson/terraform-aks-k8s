
resource "azurerm_resource_group" "rg" {
  name     = "cs-k8s-rg-${var.environment}"
  location = var.location
  tags     = var.tags
}

# User Assigned Identities 
resource "azurerm_user_assigned_identity" "user_identity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = "user-identity"

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "cs-vnet-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "k8s_sys_subnet" {
  name                 = "k8s-sys-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.0.0/24"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "k8s_usr_subnet" {
  name                 = "k8s-usr-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "app_gw_subnet" {
  name                 = "app-gw-subnet-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.5.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "app-gateway-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.app_gw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 500
  }

  tags = var.tags

  # depends_on = [azurerm_virtual_network.vnet, azurerm_public_ip.public_ip]
}

resource "azurerm_role_assignment" "ra1" {
  scope                = azurerm_subnet.k8s_sys_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id

  # depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_subnet.k8s_usr_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id

  # depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_user_assigned_identity.user_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  # depends_on           = [azurerm_user_assigned_identity.testIdentity]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = azurerm_application_gateway.app_gateway.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.user_identity.principal_id
  # depends_on           = [azurerm_user_assigned_identity.testIdentity, azurerm_application_gateway.app_gateway]
}

resource "azurerm_role_assignment" "ra5" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.user_identity.principal_id
  # depends_on           = [azurerm_user_assigned_identity.testIdentity, azurerm_application_gateway.app_gateway]
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
    network_policy = "calico"
  }

  default_node_pool {
    name                = "agentpool"
    vm_size             = "standard_d2s_v5"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    vnet_subnet_id      = azurerm_subnet.k8s_sys_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  # oms_agent {
  #   log_analytics_workspace_id = var.log_analytics_workspace_id
  # }

  # microsoft_defender {
  #   log_analytics_workspace_id = var.log_analytics_workspace_id
  # }
  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.app_gateway.id
  }
  # depends_on = [azurerm_virtual_network.vnet]
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
  vnet_subnet_id        = azurerm_subnet.k8s_usr_subnet.id

}

resource "azurerm_role_assignment" "acr_role" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "cluster_admins" {
  principal_id         = "fa48efab-4ce2-4c75-bf1d-542a4355b427"
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.k8s.id
}
