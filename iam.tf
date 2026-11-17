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
        }
        # GitHub may send the sub claim with numeric owner/repo IDs:
        #   repo:SlyyTata@286616894/eks-deployment@1460239614:ref:refs/heads/main
        # instead of the plain form:
        #   repo:SlyyTata/eks-deployment:ref:refs/heads/main
        # Accept both. Usernames and repo names can't contain "@" or "/",
        # so the wildcards only ever match the ID, never another owner or repo.
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.github_app_repo}:ref:refs/heads/${var.github_app_branch}",
            "repo:${split("/", var.github_app_repo)[0]}@*/${split("/", var.github_app_repo)[1]}@*:ref:refs/heads/${var.github_app_branch}",
          ]
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
