variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "acr_name" {
  description = "ACR name (must be globally unique)"
  type        = string
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-dev-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32.10"
}

variable "node_count" {
  description = "AKS node count"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "AKS node VM size"
  type        = string
  # FIXED: Using D2s_v3 which has available quota (6 vCPUs free)
  default     = "Standard_D2s_v3"
}
