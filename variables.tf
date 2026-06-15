variable "environment" {
  type        = string
  description = "Environment name such as dev, test, or prod"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "canadacentral"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "appenv"
}

variable "owner" {
  type        = string
  description = "Owner of the environment"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
}