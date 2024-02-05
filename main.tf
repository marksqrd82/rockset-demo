provider "aws" {
  region = local.region
}

locals {
  name            = replace(basename(path.cwd), "_", "-")
  namespace       = local.name
  cluster_version = "1.29"
  region          = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
