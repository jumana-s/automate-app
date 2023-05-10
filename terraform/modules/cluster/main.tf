data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  vpc_cidr         = "10.0.0.0/16"
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)
  account_id       = data.aws_caller_identity.current.account_id
  root_account_arn = "arn:aws:iam::${local.account_id}:root"
}

# creat vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name = "${var.env}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

resource "aws_iam_group" "group" {
  name = "cluster-access"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name = var.env

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  # configure group to have access to cluster
  aws_auth_users = [
    {
      "userarn"  = local.root_account_arn
      "username" = "root"
      "groups" = [
        aws_iam_group.group.name
      ]
    },
  ]

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      instance_type = "t3.small"
    }
  }

}
