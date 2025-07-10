# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.environment}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-aurora-subnet-group"
    Environment = var.environment
  }
}

# Aurora Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "aurora" {
  family = "aurora-mysql8.0"
  name   = "${var.environment}-aurora-cluster-parameter-group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = {
    Name        = "${var.environment}-aurora-cluster-parameter-group"
    Environment = var.environment
  }
}

# Aurora Instance Parameter Group
resource "aws_db_parameter_group" "aurora" {
  family = "aurora-mysql8.0"
  name   = "${var.environment}-aurora-parameter-group"

  # Aurora MySQL 8.0では、これらのパラメータはクラスターレベルで設定されるため、
  # インスタンスパラメータグループでは設定しない

  tags = {
    Name        = "${var.environment}-aurora-parameter-group"
    Environment = var.environment
  }
}

# Database Secret for AppSync
resource "aws_secretsmanager_secret" "database" {
  name = "${var.environment}-aurora-database-secret"

  tags = {
    Name        = "${var.environment}-aurora-database-secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "mysql"
    host     = aws_rds_cluster.aurora.endpoint
    port     = aws_rds_cluster.aurora.port
    dbname   = var.db_name
  })
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = var.cluster_identifier

  engine         = "aurora-mysql"
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password

  vpc_security_group_ids = [var.database_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  storage_encrypted = true

  tags = {
    Name        = "${var.environment}-aurora-cluster"
    Environment = var.environment
  }
}

# Aurora Writer Instance
resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier         = "${var.cluster_identifier}-writer"
  cluster_identifier = aws_rds_cluster.aurora.id

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version
  instance_class = var.instance_class

  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  db_parameter_group_name = aws_db_parameter_group.aurora.name

  auto_minor_version_upgrade = true

  tags = {
    Name        = "${var.environment}-aurora-writer"
    Environment = var.environment
  }
}

# Aurora Reader Instance
resource "aws_rds_cluster_instance" "aurora_reader" {
  identifier         = "${var.cluster_identifier}-reader"
  cluster_identifier = aws_rds_cluster.aurora.id

  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version
  instance_class = var.instance_class

  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  db_parameter_group_name = aws_db_parameter_group.aurora.name

  auto_minor_version_upgrade = true

  tags = {
    Name        = "${var.environment}-aurora-reader"
    Environment = var.environment
  }
} 