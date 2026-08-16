# End-to-End Deployment Guide

This guide details the steps to set up, build, provision, and deploy the entire DevOps practice platform on AWS.

## Environment Prerequisites

- AWS CLI v2 configured with appropriate IAM permissions.
- Terraform >= 1.5.0
- Docker & Docker Buildx
- Python 3.11+ & pytest
- Ansible >= 2.14

## Step 1: Local Application Testing

Verify the local Python application before containerizing:

```bash
cd app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
PYTHONPATH=. pytest tests/
```

Run local build script:

```bash
./scripts/build.sh v1.0.0
```

## Step 2: Infrastructure Provisioning with Terraform

Navigate to the desired environment directory:

```bash
cd terraform/environments/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Note down the outputs:
- ECR Repository URL
- ALB DNS Name
- ECS Cluster & Service names

## Step 3: Container Deployment to AWS ECS Fargate

Deploy the built application container to ECS:

```bash
./scripts/deploy.sh dev v1.0.0
```

## Step 4: Configuration Management with Ansible

Configure management jump hosts and security hardening:

```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/configure.yml
```

## Step 5: Rollback Procedure (If Needed)

If a deployment encounters issues:

```bash
./scripts/rollback.sh dev
```
