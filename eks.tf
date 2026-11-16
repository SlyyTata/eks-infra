module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project_name}-eks"
  kubernetes_version = "1.37"

  # Optional
  endpoint_public_access = true

  # Only access entries grant cluster access (no legacy aws-auth ConfigMap)
  authentication_mode = "API"

  # Admins come from var.cluster_admin_arns, not from whoever happens to run apply
  enable_cluster_creator_admin_permissions = false

  access_entries = merge(
    # Full cluster admins (CI + you)
    {
      for arn in var.cluster_admin_arns : arn => {
        principal_arn = arn
        policy_associations = {
          admin = {
            policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
            access_scope = { type = "cluster" }
          }
        }
      }
    },
    # App repo CD: can edit workloads, but only inside the app namespace
    {
      app_deploy = {
        principal_arn = aws_iam_role.app_deploy.arn
        policy_associations = {
          edit = {
            policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
            access_scope = {
              type       = "namespace"
              namespaces = [var.app_namespace]
            }
          }
        }
      }
    }
  )


  create_auto_mode_iam_resources = true
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.priv_subnet_1.id, aws_subnet.priv_subnet_2.id]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
