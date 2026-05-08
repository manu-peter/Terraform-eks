# Get AZs
data "aws_availability_zones" "available" {}

# Your key pair
data "aws_key_pair" "bastion" {
  key_name = var.key_name
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

# Bastion security group
resource "aws_security_group" "bastion_sg" {
  name        = "eks-bastion-sg"
  description = "EKS Bastion host SG"
  vpc_id      = module.vpc.vpc_id

  # SSH ONLY from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.142.31.135/32"]
  }

  # ALL outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-bastion-sg"
  }
}

# Bastion EC2 - Ubuntu 22.04 for ap-south-1
resource "aws_instance" "bastion" {
  ami           = "ami-03f4878755434977f" # Ubuntu 22.04 ap-south-1
  instance_type = "t3.micro"
  key_name      = data.aws_key_pair.bastion.key_name
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "eks-bastion"
  }
}

# EKS - PRIVATE
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = false

  eks_managed_node_groups = {
    main = {
      desired_size = 2
      min_size     = 1
      max_size     = 4

      instance_types = ["t3.medium"]
      key_name       = data.aws_key_pair.bastion.key_name
    }
  }
}
