```sh
AWS
│
├── Networking
│   ├── VPC
│   ├── Public Subnets
│   ├── Private App Subnets
│   ├── Private DB Subnets
│   ├── Internet Gateway
│   ├── NAT Gateway
│   ├── Route Tables
│   └── VPC Endpoints
│
├── Edge / Traffic
│   ├── Route 53
│   ├── ACM
│   ├── WAF
│   └── ALB
│
├── Compute
│   ├── ECS Cluster
│   ├── ECS Service
│   ├── ECS Fargate Tasks
│   └── Auto Scaling
│
├── Containers
│   └── ECR
│
├── Data
│   ├── RDS PostgreSQL
│   ├── ElastiCache Redis
│   └── S3
│
├── Security
│   ├── IAM
│   ├── Security Groups
│   ├── Secrets Manager
│   ├── KMS
│   └── WAF
│
├── Observability
│   ├── CloudWatch Logs
│   ├── CloudWatch Metrics
│   ├── CloudWatch Alarms
│   └── SNS
│
└── Management
    └── EC2 + Ansible
```


```sh
aws-devops-platform/
│
├── app/
│   ├── src/
│   ├── tests/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .dockerignore
│
├── terraform/
│   │
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   │
│   ├── modules/
│   │   ├── vpc/
│   │   ├── security/
│   │   ├── iam/
│   │   ├── ecr/
│   │   ├── ecs/
│   │   ├── alb/
│   │   ├── rds/
│   │   ├── redis/
│   │   ├── s3/
│   │   ├── secrets/
│   │   ├── cloudfront/
│   │   ├── waf/
│   │   └── monitoring/
│   │
│   └── backend/
│       └── state.tf
│
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   │   ├── bootstrap.yml
│   │   ├── hardening.yml
│   │   ├── monitoring.yml
│   │   └── configure.yml
│   └── roles/
│       ├── common/
│       ├── security/
│       └── monitoring/
│
├── .github/
│   └── workflows/
│       ├── app-ci.yml
│       ├── app-cd.yml
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       └── security.yml
│
├── scripts/
│   ├── build.sh
│   ├── deploy.sh
│   └── rollback.sh
│
├── docs/
│   ├── architecture/
│   │   ├── 01-architecture.d2
│   │   ├── 02-cicd.d2
│   │   ├── 03-aws-network.d2
│   │   └── 04-terraform.d2
│   │
│   ├── decisions/
│   ├── operations/
│   └── runbooks/
│
├── .gitignore
├── README.md
└── LICENSE
```

