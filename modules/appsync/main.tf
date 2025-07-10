# AppSync GraphQL API
resource "aws_appsync_graphql_api" "main" {
  authentication_type = var.authentication_type
  name                = var.api_name

  schema = var.schema

  tags = {
    Name        = "${var.environment}-appsync-api"
    Environment = var.environment
  }
}

# AppSync API Key
resource "aws_appsync_api_key" "main" {
  api_id = aws_appsync_graphql_api.main.id
}

# IAM Role for AppSync to access RDS
resource "aws_iam_role" "appsync_rds_role" {
  name = "${var.environment}-appsync-rds-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-appsync-rds-role"
    Environment = var.environment
  }
}

# IAM Policy for AppSync to access RDS
resource "aws_iam_role_policy" "appsync_rds_policy" {
  name = "${var.environment}-appsync-rds-policy"
  role = aws_iam_role.appsync_rds_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = var.aurora_cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.database_secret_arn
      }
    ]
  })
}

# AppSync Data Source for Aurora
resource "aws_appsync_datasource" "aurora" {
  api_id = aws_appsync_graphql_api.main.id
  name   = "aurora_datasource"
  type   = "RELATIONAL_DATABASE"
  service_role_arn = aws_iam_role.appsync_rds_role.arn

  relational_database_config {
    http_endpoint_config {
      aws_secret_store_arn = var.database_secret_arn
      db_cluster_identifier = var.aurora_cluster_identifier
      database_name = var.database_name
    }
  }
}

# AppSync Resolver for Query.activities
resource "aws_appsync_resolver" "activities" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "activities"
  type        = "Query"
  data_source = aws_appsync_datasource.aurora.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "statements": [
    "SELECT id, author, timestamp, weather, health, steps FROM activity"
  ]
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result.data)
EOF
}

# AppSync Resolver for Query.activitiesByUser
resource "aws_appsync_resolver" "activities_by_user" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "activitiesByUser"
  type        = "Query"
  data_source = aws_appsync_datasource.aurora.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "statements": [
    "SELECT id, author, timestamp, weather, health, steps FROM activity WHERE author = '$ctx.args.author'"
  ]
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result.data)
EOF
}

# AppSync Resolver for Query.buys
resource "aws_appsync_resolver" "buys" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "buys"
  type        = "Query"
  data_source = aws_appsync_datasource.aurora.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "statements": [
    "SELECT id, author, timestamp, item_name, item_price FROM buy"
  ]
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result.data)
EOF
}

# AppSync Resolver for Query.buysByUser
resource "aws_appsync_resolver" "buys_by_user" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "buysByUser"
  type        = "Query"
  data_source = aws_appsync_datasource.aurora.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "statements": [
    "SELECT id, author, timestamp, item_name, item_price FROM buy WHERE author = '$ctx.args.author'"
  ]
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result.data)
EOF
}

# AppSync Resolver for Mutation.createActivity
resource "aws_appsync_resolver" "create_activity" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "createActivity"
  type        = "Mutation"
  data_source = aws_appsync_datasource.aurora.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "statements": [
    "INSERT INTO activity (id, author, timestamp, weather, health, steps) VALUES (UUID(), '$ctx.args.author', '$ctx.args.timestamp', '$ctx.args.weather', '$ctx.args.health', $ctx.args.steps)"
  ]
}
EOF

  response_template = <<EOF
{
  "id": "$ctx.result.data[0].id",
  "author": "$ctx.args.author",
  "timestamp": "$ctx.args.timestamp",
  "weather": "$ctx.args.weather",
  "health": "$ctx.args.health",
  "steps": $ctx.args.steps
}
EOF
}

# AppSync Resolver for Mutation.createBuy
resource "aws_appsync_resolver" "create_buy" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "createBuy"
  type        = "Mutation"
  data_source = aws_appsync_datasource.aurora.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "statements": [
    "INSERT INTO buy (id, author, timestamp, item_name, item_price) VALUES (ULID(), '$ctx.args.author', '$ctx.args.timestamp', '$ctx.args.item_name', $ctx.args.item_price)"
  ]
}
EOF

  response_template = <<EOF
{
  "id": "$ctx.result.data[0].id",
  "author": "$ctx.args.author",
  "timestamp": "$ctx.args.timestamp",
  "item_name": "$ctx.args.item_name",
  "item_price": $ctx.args.item_price
}
EOF
}

# AppSync Data Source for HTTP (fallback)
resource "aws_appsync_datasource" "http" {
  api_id = aws_appsync_graphql_api.main.id
  name   = "http_datasource"
  type   = "HTTP"

  http_config {
    endpoint = "https://httpbin.org/get"
  }
}

# AppSync Resolver for Query.hello
resource "aws_appsync_resolver" "hello" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "hello"
  type        = "Query"
  data_source = aws_appsync_datasource.http.name

  request_template = <<EOF
{
  "version": "2018-05-29",
  "method": "GET",
  "resourcePath": "/get",
  "params": {
    "query": {
      "message": "Hello from AppSync!"
    }
  }
}
EOF

  response_template = <<EOF
$util.toJson("Hello from AppSync!")
EOF
} 