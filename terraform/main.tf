module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

# ECR
module "ecr" {
  source = "./modules/ecr"

  project_name    = var.project_name
  repository_name = "${var.project_name}-repo"
}

# IAM
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

# Cloudwatch
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name = var.project_name
}

# ALB
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}

# ECS
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name

  image_tag = var.image_tag

  ecr_repository_url = module.ecr.repository_url

  private_subnet_ids = module.vpc.private_subnet_ids

  execution_role_arn = module.iam.execution_role_arn

  log_group_name = module.cloudwatch.log_group_name

  target_group_arn = module.alb.target_group_arn

  ecs_security_group_id = module.alb.ecs_security_group_id

  aws_region = var.aws_region
}
