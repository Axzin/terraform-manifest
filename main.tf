terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPCとネットワーク設定
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
}

# Aurora設定
module "aurora" {
  source = "./modules/aurora"
  
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  database_security_group_id = module.vpc.database_security_group_id
  cluster_identifier       = var.aurora_cluster_identifier
  db_name                  = var.aurora_db_name
  db_username              = var.aurora_db_username
  db_password              = var.aurora_db_password
  instance_class           = var.aurora_instance_class
  engine_version           = var.aurora_engine_version
}

# AppSync設定
module "appsync" {
  source = "./modules/appsync"
  
  environment                = var.environment
  api_name                   = var.appsync_api_name
  authentication_type        = var.appsync_authentication_type
  schema                     = var.appsync_schema
  aws_region                 = var.aws_region
  aurora_cluster_identifier  = module.aurora.cluster_identifier
  aurora_cluster_arn         = module.aurora.cluster_arn
  database_secret_arn        = module.aurora.database_secret_arn
  database_name              = module.aurora.database_name
} 