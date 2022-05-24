data "azurerm_kubernetes_cluster" "aks" {
  name                = var.k8s_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_resources" "nsg" {
  resource_group_name = var.node_resource_group_name
  type                = "Microsoft.Network/networkSecurityGroups"
}

data "azurerm_resources" "route_table" {
  resource_group_name = var.node_resource_group_name
  type                = "Microsoft.Network/routeTables"
}

resource "azurerm_subnet_route_table_association" "user_route_table_association" {
  subnet_id      = var.user_subnet_id
  route_table_id = data.azurerm_resources.route_table.resources.0.id
}

resource "azurerm_subnet_route_table_association" "gateway_route_table_association" {
  subnet_id      = var.gateway_subnet_id
  route_table_id = data.azurerm_resources.route_table.resources.0.id
}

resource "azurerm_subnet_network_security_group_association" "system_nsg_association" {
  subnet_id                 = var.system_subnet_id
  network_security_group_id = data.azurerm_resources.nsg.resources.0.id
}

resource "azurerm_subnet_network_security_group_association" "user_nsg_association" {
  subnet_id                 = var.user_subnet_id
  network_security_group_id = data.azurerm_resources.nsg.resources.0.id
}
