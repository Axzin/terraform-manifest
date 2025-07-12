# AWS設定
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "default"
}

variable "use_profile" {
  description = "Whether to use AWS profile (set to false in CI/CD environments)"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# VPC設定
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# Aurora設定
variable "aurora_cluster_identifier" {
  description = "Aurora cluster identifier"
  type        = string
  default     = "user-database-cluster"
}

variable "aurora_db_name" {
  description = "Aurora database name"
  type        = string
  default     = "user_database"
}

variable "aurora_db_username" {
  description = "Aurora database username"
  type        = string
  default     = "admin"
}

variable "aurora_db_password" {
  description = "Aurora database password"
  type        = string
  sensitive   = true
}

variable "aurora_instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "aurora_engine_version" {
  description = "Aurora engine version"
  type        = string
  default     = "8.0.mysql_aurora.3.04.1"
}

# AppSync設定
variable "appsync_api_name" {
  description = "AppSync API name"
  type        = string
  default     = "user-database-graphql-api"
}

variable "appsync_authentication_type" {
  description = "AppSync authentication type"
  type        = string
  default     = "API_KEY"
}

variable "appsync_schema" {
  description = "AppSync GraphQL schema"
  type        = string
  default     = <<EOF
type Activity {
  id: ID!
  author: String!
  timestamp: String!
  weather: String
  health: String
  steps: Int!
}

type Buy {
  id: ID!
  author: String!
  timestamp: String!
  item_name: String!
  item_price: Int!
}

type Query {
  hello: String
  activities: [Activity!]!
  activitiesByUser(author: String!): [Activity!]!
  buys: [Buy!]!
  buysByUser(author: String!): [Buy!]!
}

type Mutation {
  createActivity(
    author: String!
    timestamp: String!
    weather: String
    health: String
    steps: Int!
  ): Activity!
  createBuy(
    author: String!
    timestamp: String!
    item_name: String!
    item_price: Int!
  ): Buy!
}
EOF
} 