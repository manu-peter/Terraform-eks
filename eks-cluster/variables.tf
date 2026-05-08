variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "bastion"
}
