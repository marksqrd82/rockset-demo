module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.1"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  self_managed_node_groups = {
    rockset = {
      name = "rockset"

      min_size     = 3
      max_size     = 3
      desired_size = 3

      instance_type = "t3.small"
      capacity_type = "SPOT"
    }

  }

  enable_cluster_creator_admin_permissions = true

  tags = local.tags
}
