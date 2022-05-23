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

output "current_subscription_id" {
  value = data.azurerm_subscription.current.id
}
