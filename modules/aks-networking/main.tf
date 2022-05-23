data "azurerm_kubernetes_cluster" "aks" {
  name                = "cs-k8s-dev"
  resource_group_name = "cs-k8s-rg-dev"
}

data "azurerm_resources" "nsg" {
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
  type                = "Microsoft.Network/networkSecurityGroups"
}

data "azurerm_resources" "route_table" {
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
  type                = "Microsoft.Network/routeTables"
}

data "azurerm_resources" "vnet" {
  resource_group_name = "cs-k8s-rg-dev"
  type                = "Microsoft.Network/virtualNetworks/subnets"
}

# data "azurerm_subnet" "example" {
#   name                 = "backend"
#   virtual_network_name = "production"
#   resource_group_name  = "networking"
# }

resource "azurerm_subnet_route_table_association" "route_table_association" {
  subnet_id      = "/subscriptions/d43f6c17-1989-4c36-b6a8-609a8705f996/resourceGroups/cs-k8s-rg-dev/providers/Microsoft.Network/virtualNetworks/cs-vnet-dev/subnets/k8s-usr-subnet-dev"
  route_table_id = data.azurerm_resources.route_table.resources.0.id
}
