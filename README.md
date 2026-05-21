# AWS EKS Infrastructure Provisioning with Terragrunt

This repository contains a comprehensive Infrastructure as Code (IaC) setup using Terraform and Terragrunt to provision a highly available AWS Elastic Kubernetes Service (EKS) cluster, along with its underlying Virtual Private Cloud (VPC) and essential Kubernetes add-ons.

---

## Use Case & Architecture Overview

This setup is designed for scalable, production-ready Kubernetes environments, abstracting the complexity of AWS networking and EKS control plane management. By utilizing Terragrunt, the architecture keeps configurations DRY (Don't Repeat Yourself) across multiple environments (e.g., `dev` and `staging`).

The automation provisions the following components:

### VPC Infrastructure
- Dedicated VPC
- Public and private subnets across multiple Availability Zones
- Internet Gateway
- NAT Gateway
- Route tables

### EKS Cluster
- Managed Kubernetes control plane
- Managed node groups
- Support for both:
  - `ON_DEMAND`
  - `SPOT` instances

### IAM Roles for Service Accounts (IRSA) & Pod Identity
- Secure and least-privilege IAM access for Kubernetes workloads

### EKS Add-ons
- **AWS VPC CNI**
  - Native AWS networking for Kubernetes pods

- **Cluster Autoscaler**
  - Automatically scales worker nodes based on pod resource requests

- **AWS EBS CSI Driver**
  - Provides lifecycle management for Amazon EBS volumes

- **AWS Load Balancer Controller**
  - Manages:
    - Application Load Balancers (ALB) for Ingress
    - Network Load Balancers (NLB) for Services

- **EKS Pod Identity Agent**
  - Simplifies IAM permission management for applications running on EKS

---

# Prerequisites

Ensure the following tools are installed and configured:

| Tool | Version |
|------|----------|
| Terraform | `>= 1.0` |
| Terragrunt | Latest |
| AWS CLI | v2 |
| kubectl | Matching EKS version (e.g., `1.35`) |
| Helm | `v3.1.1+` |

---

# AWS Account Preparation

## S3 Backend
Create an S3 bucket for Terraform remote state storage:

- Bucket Name: `dreams-unlimited`
- Region: `ap-south-1`
- Enable versioning

## IAM Role
Create an IAM role named:

```bash
terraform
```

Attach:

- `AdministratorAccess`

## IAM User Policy
Create a policy named:

```bash
AllowTerraform
```

This policy should allow assuming the `terraform` IAM role.

## Local AWS Credentials
Configure your local AWS credentials:

```bash
~/.aws/credentials
```

---

# Repository Structure

```bash
terragrunt-eks-module/
├── vpc/
├── eks/
└── eks-addons/

terragrunt-eks-live/
├── dev/
└── staging/
```

### Description

| Directory | Purpose |
|-----------|---------|
| `terragrunt-eks-module/` | Reusable and versioned Terraform modules |
| `terragrunt-eks-live/` | Live environment Terragrunt configurations |
| `dev/` | Development environment |
| `staging/` | Staging environment |

---

# Step-by-Step Setup Guide

## 1. Configure the Environment

Update the following files in both `dev` and `staging` environments:

- `terragrunt.hcl`
- `env.hcl`

Configure:
- AWS Account ID
- IAM Role ARN
- AWS profile names

---

## 2. Initialize the Infrastructure

Navigate to your desired environment:

```bash
cd terragrunt-eks-live/dev
```

Initialize Terragrunt:

```bash
terragrunt run-all init -upgrade
```

---

## 3. Review the Execution Plan

```bash
terragrunt run-all plan
```

---

## 4. Apply the Infrastructure

```bash
terragrunt run-all apply --non-interactive
```

---

# Post-Provisioning Verification

## Connect to the Cluster

Generate the kubeconfig file:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name dev-demo \
  --profile amit \
  --role-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:role/terraform
```

---

## Validate EKS Add-ons

Deploy the demo applications available in the `demo/` folder to validate:

- Cluster Autoscaler
- AWS Load Balancer Controller
- AWS EBS CSI Driver

---

# Clean Up

Destroy the infrastructure:

```bash
cd terragrunt-eks-live/dev

terragrunt run-all destroy --non-interactive
```

---

# Notes

- Recommended for multi-environment Kubernetes deployments on AWS
- Designed with reusable Terraform modules and Terragrunt orchestration
- Supports production-grade networking and autoscaling patterns
- Uses IRSA and Pod Identity for secure AWS access from workloads