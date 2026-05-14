data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  tags               = var.tags
}


module "security-groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  allowed_ssh_cidr_blocks = var.allowed_ssh_cidr_blocks
  tags                    = var.tags
}


module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "alb" {
  source                = "../../modules/alb"
  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.security-groups.alb_security_group_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  health_check_path     = "/health"
  tags                  = var.tags
}


module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids

  ec2_security_group_id = module.security-groups.ec2_security_group_id
  target_group_arn      = module.alb.target_group_arn

  instance_profile_name = module.iam.ec2_instance_profile_name

  instance_type = var.instance_type

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  tags = var.tags
}