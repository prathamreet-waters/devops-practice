resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = var.tags
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.environment}-redis"
  description          = "Redis replication group for ${var.environment}"
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.security_group_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = var.tags
}
