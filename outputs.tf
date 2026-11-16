output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_deploy_role_arn" {
  description = "Set as the AWS_DEPLOY_ROLE_ARN variable in the app repo's GitHub settings"
  value       = aws_iam_role.app_deploy.arn
}

output "eks_cluster_name" {
  description = "Use with: aws eks update-kubeconfig --name <this> --region <region>"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API server URL"
  value       = module.eks.cluster_endpoint
}

output "app_namespace" {
  description = "Namespace the app repo's CD may deploy into"
  value       = var.app_namespace
}
