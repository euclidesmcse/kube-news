output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Nome do Resource Group"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "URL do Azure Container Registry"
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "Nome do ACR"
}

output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "ID do ACR"
}

output "aks_dev_id" {
  value       = azurerm_kubernetes_cluster.aks_dev.id
  description = "ID do cluster AKS DEV"
}

output "aks_dev_name" {
  value       = azurerm_kubernetes_cluster.aks_dev.name
  description = "Nome do cluster AKS DEV"
}

output "aks_dev_fqdn" {
  value       = azurerm_kubernetes_cluster.aks_dev.fqdn
  description = "FQDN do cluster AKS DEV"
}

output "aks_prod_id" {
  value       = azurerm_kubernetes_cluster.aks_prod.id
  description = "ID do cluster AKS PROD"
}

output "aks_prod_name" {
  value       = azurerm_kubernetes_cluster.aks_prod.name
  description = "Nome do cluster AKS PROD"
}

output "aks_prod_fqdn" {
  value       = azurerm_kubernetes_cluster.aks_prod.fqdn
  description = "FQDN do cluster AKS PROD"
}

output "kube_config_dev" {
  value       = azurerm_kubernetes_cluster.aks_dev.kube_config
  sensitive   = true
  description = "Kubeconfig do cluster DEV"
}

output "kube_config_prod" {
  value       = azurerm_kubernetes_cluster.aks_prod.kube_config
  sensitive   = true
  description = "Kubeconfig do cluster PROD"
}
