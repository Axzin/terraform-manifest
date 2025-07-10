variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "database_security_group_id" {
  description = "Database security group ID"
  type        = string
}

variable "cluster_identifier" {
  description = "Aurora cluster identifier"
  type        = string
}

variable "db_name" {
  description = "Aurora database name"
  type        = string
}

variable "db_username" {
  description = "Aurora database username"
  type        = string
}

variable "db_password" {
  description = "Aurora database password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Aurora instance class"
  type        = string
}

variable "engine_version" {
  description = "Aurora engine version"
  type        = string
} 