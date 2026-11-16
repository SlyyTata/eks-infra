variable "project_name" {
  description = "Prefix used to name resources so they don't clash with other stacks"
  type        = string

  validation {
    # ALB / target group names are limited to 32 characters
    condition     = length(var.project_name) <= 20 && can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "project_name must be 20 characters or fewer and contain only letters, numbers and hyphens."
  }
}

variable "cluster_admin_arns" {
  description = "IAM role/user ARNs given full admin on the EKS cluster (e.g. the CI role and your own IAM user/role)"
  type        = list(string)

  validation {
    condition     = length(var.cluster_admin_arns) > 0
    error_message = "At least one cluster admin is required, or nobody can manage the cluster."
  }
}

variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
}

# ---------- Networking ----------
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "pub_subnet_cidr_block_1" {
  description = "The CIDR block for the first public subnet"
  type        = string
}

variable "pub_subnet_cidr_block_2" {
  description = "The CIDR block for the second public subnet"
  type        = string
}

variable "priv_subnet_cidr_block_1" {
  description = "The CIDR block for the first private subnet"
  type        = string
}

variable "priv_subnet_cidr_block_2" {
  description = "The CIDR block for the second private subnet"
  type        = string
}


# ---------- App CD (GitHub Actions OIDC) ----------
variable "github_app_repo" {
  description = "owner/repo whose CD workflow may deploy new images to the ECS services"
  type        = string
}

variable "github_app_branch" {
  description = "Only workflow runs on this branch of github_app_repo can assume the deploy role"
  type        = string
  default     = "main"
}

variable "app_namespace" {
  description = "Kubernetes namespace the app repo's CD role is allowed to deploy into"
  type        = string
}
