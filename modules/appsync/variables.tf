variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_name" {
  description = "AppSync API name"
  type        = string
}

variable "authentication_type" {
  description = "AppSync authentication type"
  type        = string
}

variable "schema" {
  description = "AppSync GraphQL schema"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aurora_cluster_identifier" {
  description = "Aurora cluster identifier"
  type        = string
}

variable "aurora_cluster_arn" {
  description = "Aurora cluster ARN"
  type        = string
}

variable "database_secret_arn" {
  description = "Database secret ARN"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
} 