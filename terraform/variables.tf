variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "kubenews"
}

variable "location" {
  description = "Localização dos recursos Azure"
  type        = string
  default     = "eastus"
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.28"
}

variable "aks_dev_node_count" {
  description = "Número de nós no cluster DEV"
  type        = number
  default     = 1
}

variable "aks_prod_node_count" {
  description = "Número de nós no cluster PROD"
  type        = number
  default     = 3
}

variable "aks_vm_size" {
  description = "Tamanho das VMs do AKS"
  type        = string
  default     = "Standard_B2s"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "production"
}
