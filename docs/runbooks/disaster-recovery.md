# Disaster Recovery Runbook

This document defines the Disaster Recovery (DR) procedures for the AWS DevOps Platform.

## Target Recovery Metrics

- **Recovery Point Objective (RPO)**: < 1 hour
- **Recovery Time Objective (RTO)**: < 2 hours

## Scenario 1: RDS Database Restoration from Point-in-Time Backup

1. List available DB snapshots:
   ```bash
   aws rds describe-db-snapshots --db-instance-identifier dev-postgres
   ```

2. Restore DB instance from snapshot:
   ```bash
   aws rds restore-db-instance-from-db-snapshot \
     --db-instance-identifier dev-postgres-restored \
     --db-snapshot-identifier <snapshot-id> \
     --db-subnet-group-name dev-db-subnet-group \
     --vpc-security-group-ids <security-group-id>
   ```

3. Update application connection parameters via AWS Secrets Manager:
   ```bash
   aws secretsmanager update-secret \
     --secret-id dev/app/config \
     --secret-string '{"DB_HOST":"dev-postgres-restored.xxxx.ap-south-2.rds.amazonaws.com"}'
   ```

## Scenario 2: Complete Regional Failover / Infrastructure Rebuilding

1. Export S3 asset backup data if applicable.
2. Initialize Terraform in secondary region or clean environment state:
   ```bash
   cd terraform/environments/prod
   terraform init -reconfigure
   terraform apply -auto-approve
   ```
3. Trigger application deployment pipeline via GitHub Actions workflow dispatch.
