module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
}

module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

module "security_groups" {
  source       = "./modules/security-groups"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
}

module "jump_server" {
  source           = "./modules/jump-server"
  cluster_name     = var.cluster_name
  key_name         = var.key_name
  public_subnet_id = module.vpc.public_subnets[0]
  bastion_sg_id    = module.security_groups.bastion_sg_id
}

module "eks_cluster" {
  source              = "./modules/eks-cluster"
  cluster_name        = var.cluster_name
  cluster_role_arn    = module.iam.cluster_role_arn
  private_subnet_ids  = module.vpc.private_subnets
  cluster_sg_id       = module.security_groups.cluster_sg_id
}

module "eks_nodegroup" {
  source             = "./modules/eks-nodegroup"
  cluster_name       = module.eks_cluster.cluster_name
  node_role_arn      = module.iam.node_role_arn
  private_subnet_ids = module.vpc.private_subnets
  key_name           = var.key_name
}
