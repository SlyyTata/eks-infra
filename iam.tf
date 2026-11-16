# Reuse the account's existing GitHub OIDC provider
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "app_deploy" {
  name = "${var.project_name}-app-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_app_repo}:ref:refs/heads/${var.github_app_branch}"
        }
      }
    }]
  })
}

# Lets the app repo's CD build a kubeconfig for this cluster only.
# What it can do inside the cluster is set by its access entry in eks.tf.
resource "aws_iam_role_policy" "app_deploy" {
  name = "eks-deploy"
  role = aws_iam_role.app_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "Kubeconfig"
      Effect   = "Allow"
      Action   = "eks:DescribeCluster"
      Resource = module.eks.cluster_arn
    }]
  })
}
