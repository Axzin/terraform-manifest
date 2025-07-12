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
  # ローカル開発時のみプロファイルを使用（GitHub Actionsでは環境変数を使用）
  profile = var.use_profile ? var.aws_profile : null
}

# VPCとネットワーク設定
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  environment        = var.environment
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

# Aurora設定
module "aurora" {
  source = "./modules/aurora"

  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  database_security_group_id = module.vpc.database_security_group_id
  cluster_identifier         = var.aurora_cluster_identifier
  db_name                    = var.aurora_db_name
  db_username                = var.aurora_db_username
  db_password                = var.aurora_db_password
  instance_class             = var.aurora_instance_class
  engine_version             = var.aurora_engine_version
}

# AppSync設定
module "appsync" {
  source = "./modules/appsync"

  environment               = var.environment
  api_name                  = var.appsync_api_name
  authentication_type       = var.appsync_authentication_type
  schema                    = var.appsync_schema
  aws_region                = var.aws_region
  aurora_cluster_identifier = module.aurora.cluster_identifier
  aurora_cluster_arn        = module.aurora.cluster_arn
  database_secret_arn       = module.aurora.database_secret_arn
  database_name             = module.aurora.database_name
}

# 最新のUbuntu 20.04 LTS AMIを取得
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# EC2用セキュリティグループ（SSH許可）
resource "aws_security_group" "ec2_ssh" {
  name        = "ec2-ssh"
  description = "Allow SSH from anywhere (change to your IP for security)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # セキュリティのため自分のIPに限定推奨
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ubuntu EC2インスタンス（Prisma CLIセットアップ付き）
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_ssh.id]
  key_name                    = "yomi4486"
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y curl nodejs npm
    npm install -g prisma
  EOF
} 