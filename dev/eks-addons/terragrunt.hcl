terraform {
  source = "git@github.com:amitactive2008/terragrunt-eks-module.git//eks-addons?ref=0.1.1"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}
# 1. Pull down the VPC outputs
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock12345"
  }
}

dependency "eks" {
  config_path = "../eks"
  skip_outputs                             = false
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]

  mock_outputs = {
    eks_name            = "demo"
    openid_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/MOCK123456789"
  }
}

inputs = {
  env      = include.env.locals.env
  eks_name = dependency.eks.outputs.eks_name
  openid_provider_arn = dependency.eks.outputs.openid_provider_arn
  vpc_id              = dependency.vpc.outputs.vpc_id
  aws_region          = "us-east-1"

#  enable_eks_oidc                = true
  aws-vpc-cni-version             = "v1.21.2-eksbuild.2"
  enable_eks_pod_identity         = true
  pod_identity_addon_version      = "v1.3.10-eksbuild.3"

  enable_cluster_autoscaler      = true
  cluster_autoscaler_helm_verion = "9.57.0"
  
  enable_ebs_csi_driver           = true

  enable_lb_controller            = true # Make sure to enable enable_eks_pod_identity also if you are enabling lb_controller

}

generate "helm_provider" {
  path      = "helm-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

data "aws_eks_cluster" "eks" {
    name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.eks_name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name, "--profile", "${include.env.locals.aws_profile}", "--role-arn", "${include.env.locals.role-arn}"]
      command     = "aws"
    }
  }
}
EOF
}
