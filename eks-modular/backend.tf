terraform {
  backend "s3" {
    bucket         = "my-eks-terraform-state-383158157516"
    key            = "eks-modular/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
