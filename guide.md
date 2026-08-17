# Complete Setup Guide

A step-by-step guide to get this project running from zero to deployed on AWS.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Repository Setup on GitHub](#2-repository-setup-on-github)
3. [AWS Account Setup](#3-aws-account-setup)
4. [Terraform Remote State Bootstrap](#4-terraform-remote-state-bootstrap)
5. [GitHub Actions Secrets Configuration](#5-github-actions-secrets-configuration)
6. [Deploy Infrastructure with Terraform](#6-deploy-infrastructure-with-terraform)
7. [Build and Push Your First Container Image](#7-build-and-push-your-first-container-image)
8. [Verify the Running Application](#8-verify-the-running-application)
9. [Ansible Server Configuration (Optional)](#9-ansible-server-configuration-optional)
10. [Day-to-Day Workflow](#10-day-to-day-workflow)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Prerequisites

Install these tools on your local machine before starting:

| Tool | Version | Purpose |
|------|---------|---------|
| AWS CLI v2 | >= 2.x | Interact with AWS services |
| Terraform | >= 1.5.0 | Provision infrastructure |
| Docker | >= 24.x | Build container images |
| Python | >= 3.11 | Run and test the application |
| Git | >= 2.x | Version control |
| Ansible | >= 2.14 | Server configuration (optional) |

### Verify installations

```bash
aws --version
terraform --version
docker --version
python3 --version
git --version
```

---

## 2. Repository Setup on GitHub

### 2.1 Push to GitHub (if not already)

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/devops-practice.git
git push -u origin main
```

### 2.2 Branch protection (recommended)

Go to GitHub repository > Settings > Branches > Add rule:
- Branch name pattern: `main`
- Check "Require pull request reviews before merging"
- Check "Require status checks to pass before merging"

This ensures all changes go through CI before merging.

---

## 3. AWS Account Setup

### 3.1 Create an IAM User for CLI access

1. Go to AWS Console > IAM > Users > Create User.
2. Name it `devops-admin`.
3. Attach the policy `AdministratorAccess` (for learning only, scope it down for production).
4. Create access keys (CLI type).
5. Configure locally:

```bash
aws configure
# Enter your Access Key ID, Secret Access Key, Region (us-east-1), Output (json)
```

### 3.2 Verify access

```bash
aws sts get-caller-identity
```

You should see your account ID, user ARN, etc.

### 3.3 Set up GitHub OIDC Identity Provider in AWS

This lets GitHub Actions authenticate to AWS without storing long-lived credentials.

1. Go to AWS Console > IAM > Identity providers > Add provider.
2. Select OpenID Connect.
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Click "Add provider".

### 3.4 Create the GitHub OIDC IAM Role

1. Go to IAM > Roles > Create Role.
2. Trusted entity type: Web identity.
3. Identity provider: `token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Add condition: `token.actions.githubusercontent.com:sub` StringLike `repo:YOUR_USERNAME/devops-practice:*`
6. Attach policies:
   - `AmazonECS_FullAccess`
   - `AmazonEC2ContainerRegistryPowerUser`
   - `AmazonVPCFullAccess`
   - `IAMFullAccess`
   - `AmazonS3FullAccess`
   - `AmazonRDSFullAccess`
   - `CloudWatchFullAccess`
   - `ElastiCacheFullAccess`
   - `AWSWAFFullAccess`
   - `CloudFrontFullAccess`
   - `SecretsManagerReadWrite`
   - `AmazonDynamoDBFullAccess` (for Terraform state locking)
   - `AmazonSNSFullAccess`
7. Role name: `github-actions-oidc-role`
8. Copy the Role ARN (you will need it for GitHub Secrets).

---

## 4. Terraform Remote State Bootstrap

Before running any Terraform, you need to create the S3 bucket and DynamoDB table that store the Terraform state.

Run these commands once from your terminal:

```bash
# Create the S3 bucket for state
aws s3api create-bucket \
  --bucket devops-practice-tfstate-global \
  --region us-east-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket devops-practice-tfstate-global \
  --versioning-configuration Status=Enabled

# Enable encryption on the bucket
aws s3api put-bucket-encryption \
  --bucket devops-practice-tfstate-global \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access on the bucket
aws s3api put-public-access-block \
  --bucket devops-practice-tfstate-global \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name devops-practice-tfstate-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Verify they exist:

```bash
aws s3 ls | grep devops-practice-tfstate
aws dynamodb describe-table --table-name devops-practice-tfstate-locks --query "Table.TableStatus"
```

---

## 5. GitHub Actions Secrets Configuration

Go to your GitHub repository > Settings > Secrets and variables > Actions > New repository secret.

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `AWS_OIDC_ROLE_ARN` | The ARN from Step 3.4 (e.g. `arn:aws:iam::123456789012:role/github-actions-oidc-role`) |

That is the only secret needed. OIDC handles authentication without access keys.

---

## 6. Deploy Infrastructure with Terraform

Start with the dev environment. Run from your local terminal:

```bash
cd terraform/environments/dev

# Initialize Terraform (downloads providers, connects to backend)
terraform init

# Preview what will be created
terraform plan

# If the plan looks good, apply it
terraform apply
```

This creates:
- VPC with public/private subnets across 2 AZs
- NAT Gateway, Internet Gateway, Route Tables
- Security Groups (ALB, ECS, RDS, Redis)
- IAM Roles (ECS execution, task)
- ECR Repository
- Application Load Balancer
- ECS Fargate Cluster and Service
- RDS PostgreSQL Database
- ElastiCache Redis
- S3 Bucket
- Secrets Manager
- CloudWatch Alarms and SNS Topic

After apply finishes, note the outputs:

```bash
terraform output
```

Save the `ecr_repository_url` and `alb_dns_name` values.

---

## 7. Build and Push Your First Container Image

### 7.1 Build locally

```bash
cd ../../..  # back to project root

# Build the Docker image
docker build -t devops-app:latest ./app

# Test it locally
docker run -d -p 8000:8000 devops-app:latest
curl http://localhost:8000/health
docker stop $(docker ps -q --filter ancestor=devops-app:latest)
```

### 7.2 Push to ECR

```bash
# Get your AWS account ID and ECR URL from terraform output
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/dev-devops-app"

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Tag and push
docker tag devops-app:latest ${ECR_URL}:latest
docker push ${ECR_URL}:latest
```

### 7.3 Update ECS Service to pick up the new image

```bash
aws ecs update-service \
  --cluster dev-cluster \
  --service dev-service \
  --force-new-deployment \
  --region us-east-1
```

---

## 8. Verify the Running Application

### 8.1 Get the ALB DNS name

```bash
cd terraform/environments/dev
terraform output alb_dns_name
```

### 8.2 Test endpoints

```bash
ALB_DNS="your-alb-dns-name-here"

curl http://${ALB_DNS}/
curl http://${ALB_DNS}/health
curl http://${ALB_DNS}/ready
curl http://${ALB_DNS}/api/v1/info
curl http://${ALB_DNS}/metrics
```

All should return JSON responses with 200 status.

---

## 9. Ansible Server Configuration (Optional)

Only needed if you have an EC2 jump host / bastion server to configure.

### 9.1 Update inventory

Edit `ansible/inventory/hosts.ini` with your actual EC2 instance IP and SSH key path.

### 9.2 Run the master playbook

```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/configure.yml
```

This applies:
- System updates and common packages
- Firewall (UFW) and SSH hardening
- Prometheus Node Exporter for monitoring

---

## 10. Day-to-Day Workflow

### Making application changes

1. Create a branch: `git checkout -b feature/my-change`
2. Make your code changes in `app/src/`.
3. Push and open a Pull Request to `main`.
4. The `app-ci.yml` workflow runs tests, builds Docker, and scans for vulnerabilities.
5. After PR is approved and merged, `app-cd.yml` automatically builds, pushes to ECR, and deploys to ECS.

### Making infrastructure changes

1. Create a branch: `git checkout -b infra/my-change`
2. Modify files in `terraform/`.
3. Push and open a Pull Request to `main`.
4. The `terraform-plan.yml` workflow runs `terraform plan` against all environments.
5. Review the plan output in the PR.
6. After merge, `terraform-apply.yml` runs `terraform apply` for dev.

### Manual deployment (using scripts)

```bash
# Build
./scripts/build.sh v1.0.1

# Deploy to dev
./scripts/deploy.sh dev v1.0.1

# Rollback if something goes wrong
./scripts/rollback.sh dev
```

---

## 11. Troubleshooting

### ECS tasks keep crashing

Check CloudWatch logs:
```bash
aws logs tail /ecs/dev-app --follow
```

### Terraform init fails

Make sure the S3 bucket and DynamoDB table from Step 4 exist:
```bash
aws s3 ls | grep devops-practice-tfstate
aws dynamodb describe-table --table-name devops-practice-tfstate-locks
```

### Docker build fails locally

Check you are building from the right directory:
```bash
docker build -t devops-app:latest ./app
```

### GitHub Actions OIDC fails

Verify:
1. The OIDC provider is set up in IAM.
2. The role trust policy has your correct GitHub repo name.
3. The `AWS_OIDC_ROLE_ARN` secret in GitHub is correct.

### Cannot connect to ALB

Check Security Groups allow inbound traffic on port 80/443:
```bash
aws ec2 describe-security-groups --filters "Name=group-name,Values=dev-alb-sg"
```

### Terraform destroy (cleanup)

When you are done and want to tear everything down to avoid costs:

```bash
cd terraform/environments/dev
terraform destroy
```

Then delete the state resources:

```bash
aws s3 rb s3://devops-practice-tfstate-global --force
aws dynamodb delete-table --table-name devops-practice-tfstate-locks
```
