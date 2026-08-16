# Incident Response Runbook

Operational procedures for responding to CloudWatch alarms and application incidents.

## High CPU / Memory Alarm on ECS Service

1. Check current ECS task CPU/Memory utilization in CloudWatch metrics:
   ```bash
   aws cloudwatch get-metric-statistics \
     --namespace AWS/ECS \
     --metric-name CPUUtilization \
     --dimensions Name=ClusterName,Value=dev-cluster Name=ServiceName,Value=dev-service \
     --start-time $(date -u -v-1H +%Y-%m-%dT%H:%M:%SZ) \
     --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
     --period 300 \
     --statistics Average
   ```

2. Scale out ECS service tasks manually if autoscaling is delayed:
   ```bash
   aws ecs update-service \
     --cluster dev-cluster \
     --service dev-service \
     --desired-count 5
   ```

## High HTTP 5xx Error Spike on ALB

1. Fetch live application logs from CloudWatch log group `/ecs/dev-app`:
   ```bash
   aws logs tail /ecs/dev-app --follow --filter-pattern "ERROR"
   ```

2. If caused by a faulty deployment, execute immediate rollback:
   ```bash
   ./scripts/rollback.sh dev
   ```
