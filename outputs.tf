# VPC出力
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# Aurora出力
output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.aurora.cluster_endpoint
}

output "aurora_cluster_port" {
  description = "Aurora cluster port"
  value       = module.aurora.cluster_port
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.aurora.reader_endpoint
}

# AppSync出力
output "appsync_graphql_url" {
  description = "AppSync GraphQL URL"
  value       = module.appsync.graphql_url
}

output "appsync_api_key" {
  description = "AppSync API key"
  value       = module.appsync.api_key
  sensitive   = true
} 