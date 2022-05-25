# ---------------------------------------------------------------------------------------------------------------------
# KUBERNETES CONNECTION INFORMATION
# The outputs allow you to connect the Terraform Kubernetes and Helm providers once the cluster is created.
# ---------------------------------------------------------------------------------------------------------------------

output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the cluster. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#client_certificate"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_certificate
}

output "client_key" {
  description = "Private key used by clients to authenticate to the cluster. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#client_key"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Public CA cert used as root of trust. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#cluster_ca_certificate"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Cluster server host. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#host"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config.0.host
}

output "kube_config_raw" {
  description = "Raw K8s config used by `kubectl` CLI. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#kube_admin_config_raw"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config_raw
  sensitive   = true
}

# ---------------------------------------------------------------------------------------------------------------------
# AKS Cluster Information
# These outputs are used by the subsequent AKS Networking module to connect subnets to route tables and security groups
# ---------------------------------------------------------------------------------------------------------------------

output "cluster_name" {
  description = "The name of the cluster in Azure."
  value       = azurerm_kubernetes_cluster.k8s.name
}

output "system_subnet_id" {
  description = "Subnet ID added to the default/system node pool"
  value       = data.azurerm_subnet.sys_subnet.id
}

output "user_subnet_id" {
  description = "Subnet ID added to the user node pool"
  value       = data.azurerm_subnet.usr_subnet.id
}

output "gateway_subnet_id" {
  description = "Subnet ID added to the Azure Application Gateway Ingress Controller"
  value       = data.azurerm_subnet.gw_subnet.id
}

output "resource_group_name" {
  description = "AKS parent resource group name."
  value       = azurerm_resource_group.rg.name
}

output "node_resource_group_name" {
  description = "AKS node parent resource group name."
  value       = azurerm_kubernetes_cluster.k8s.node_resource_group
}
