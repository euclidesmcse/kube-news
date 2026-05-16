terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # Configurar no pipeline com -backend-config
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion            = true
      graceful_shutdown                     = false
      skip_shutdown_and_force_delete        = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}"
  location = var.location

  tags = local.common_tags
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.project_name, "-", "")}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = local.common_tags
}

# AKS Cluster - DEV
resource "azurerm_kubernetes_cluster" "aks_dev" {
  name                = "aks-${var.project_name}-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.project_name}-dev"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.aks_dev_node_count
    vm_size             = var.aks_vm_size
    type                = "VirtualMachineScaleSets"
    availability_zones  = ["1", "2"]

    tags = local.common_tags
  }

  service_principal {
    client_id     = azuread_service_principal.aks.client_id
    client_secret = azuread_service_principal_password.aks.value
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr      = "10.0.0.0/16"
  }

  tags = local.common_tags

  depends_on = [
    azuread_service_principal_password.aks
  ]
}

# AKS Cluster - PROD
resource "azurerm_kubernetes_cluster" "aks_prod" {
  name                = "aks-${var.project_name}-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${var.project_name}-prod"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.aks_prod_node_count
    vm_size             = var.aks_vm_size
    type                = "VirtualMachineScaleSets"
    availability_zones  = ["1", "2", "3"]
    max_pods            = 110

    tags = local.common_tags
  }

  service_principal {
    client_id     = azuread_service_principal.aks.client_id
    client_secret = azuread_service_principal_password.aks.value
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr      = "10.0.0.0/16"
  }

  tags = local.common_tags

  depends_on = [
    azuread_service_principal_password.aks
  ]
}

# Role Assignment - ACR para AKS (DEV)
resource "azurerm_role_assignment" "aks_dev_acr" {
  scope              = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id       = azuread_service_principal.aks.object_id
}

# Role Assignment - ACR para AKS (PROD)
resource "azurerm_role_assignment" "aks_prod_acr" {
  scope              = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id       = azuread_service_principal.aks.object_id
}

# Kubernetes Namespace - PROD
resource "kubernetes_namespace" "kubenews_prod" {
  metadata {
    name = "kubenews"
  }

  depends_on = [azurerm_kubernetes_cluster.aks_prod]
}

# Locals
locals {
  common_tags = {
    Project     = var.project_name
    Environment = "shared"
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}
