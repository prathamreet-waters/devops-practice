provider "aws" {
  region = var.aws_region
}

locals {
  environment = "prod"
  tags = {
    Environment = local.environment
    Project     = "DevOps-Practice"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source                   = "../../modules/vpc"
  environment              = local.environment
  vpc_cidr                 = "10.30.0.0/16"
  public_subnet_cidrs      = ["10.30.1.0/24", "10.30.2.0/24"]
  private_app_subnet_cidrs  = ["10.30.10.0/24", "10.30.11.0/24"]
  private_db_subnet_cidrs   = ["10.30.20.0/24", "10.30.21.0/24"]
  single_nat_gateway       = false
  tags                     = local.tags
}

module "security" {
  source      = "../../modules/security"
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  app_port    = 8000
  tags        = local.tags
}

module "iam" {
  source           = "../../modules/iam"
  environment      = local.environment
  create_oidc_role = true
  tags             = local.tags
}

module "ecr" {
  source          = "../../modules/ecr"
  environment     = local.environment
  repository_name = "devops-app"
  tags            = local.tags
}

module "alb" {
  source            = "../../modules/alb"
  environment       = local.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security.alb_sg_id
  app_port          = 8000
  health_check_path = "/health"
  tags              = local.tags
}

module "waf" {
  source      = "../../modules/waf"
  environment = local.environment
  alb_arn     = module.alb.alb_arn
  tags        = local.tags
}

module "cloudfront" {
  source       = "../../modules/cloudfront"
  environment  = local.environment
  alb_dns_name = module.alb.alb_dns_name
  tags         = local.tags
}

module "ecs" {
  source             = "../../modules/ecs"
  environment        = local.environment
  aws_region         = var.aws_region
  container_image    = "${module.ecr.repository_url}:latest"
  container_port     = 8000
  desired_count      = 3
  min_count          = 2
  max_count          = 10
  private_subnet_ids = module.vpc.private_app_subnet_ids
  security_group_id  = module.security.ecs_task_sg_id
  target_group_arn   = module.alb.target_group_arn
  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  tags               = local.tags
}

module "rds" {
  source                = "../../modules/rds"
  environment           = local.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  security_group_id     = module.security.rds_sg_id
  db_instance_class     = "db.m6g.large"
  allocated_storage     = 50
  multi_az              = true
  tags                  = local.tags
}

module "redis" {
  source                = "../../modules/redis"
  environment           = local.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  security_group_id     = module.security.redis_sg_id
  node_type             = "cache.m6g.large"
  num_cache_clusters   = 2
  tags                  = local.tags
}

module "s3" {
  source      = "../../modules/s3"
  environment = local.environment
  tags        = local.tags
}

module "secrets" {
  source      = "../../modules/secrets"
  environment = local.environment
  tags        = local.tags
}

module "monitoring" {
  source           = "../../modules/monitoring"
  environment      = local.environment
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  tags             = local.tags
}
