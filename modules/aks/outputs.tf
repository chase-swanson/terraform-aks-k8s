output "client_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_certificate
}

output "client_key" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_key
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.host
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.k8s.kube_admin_config_raw
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "system_subnet_id" {
  value = data.azurerm_subnet.sys_subnet.id
}

output "user_subnet_id" {
  value = data.azurerm_subnet.usr_subnet.id
}

output "gateway_subnet_id" {
  value = data.azurerm_subnet.gw_subnet.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "node_resource_group_name" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
}
