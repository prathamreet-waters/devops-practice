# ADR 001: DevOps Architectural Stack Selection

## Status

Accepted

## Context

The objective is to establish an end-to-end, production-grade DevOps practice platform focused on cloud infrastructure automation, container deployment, configuration management, security governance, and CI/CD pipelines.

## Decision

1. **Application Layer**: Lightweight Python microservice returning JSON responses, health checks, readiness probes, and Prometheus metrics.
2. **Infrastructure as Code**: Terraform 1.5+ utilizing a modular architecture (13 reusable modules across VPC, Security, IAM, ECR, ECS, ALB, RDS, Redis, S3, Secrets Manager, CloudFront, WAF, Monitoring) and 3 environments (`dev`, `staging`, `prod`).
3. **Container Orchestration**: AWS ECS Fargate serverless container platform instead of Kubernetes to focus heavily on core AWS cloud-native patterns.
4. **Configuration Management**: Ansible playbooks and roles (`common`, `security`, `monitoring`) for managing EC2 jump hosts and bastion servers.
5. **CI/CD Pipeline**: GitHub Actions using AWS OIDC authentication, automated linting, unit testing (`pytest`), Docker build verification, Trivy vulnerability scanning, and automated ECS deployment.

## Consequences

- Highly scalable, maintainable, and easy-to-understand DevOps codebase.
- Avoids unnecessary application code bloat, allowing maximum focus on DevOps practices.
