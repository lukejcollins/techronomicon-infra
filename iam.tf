# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# This block creates an inline IAM role policy named "ecs_task_execution_role_policy" for the role specified
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "ecs_task_execution_role_policy"
  role   = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = "*"
      }
    ]
  })
}

# This block fetches information about the AWS account, including the account ID
data "aws_caller_identity" "current" {}

# This block creates a managed IAM policy called "parameter_store_access"
resource "aws_iam_policy" "parameter_store_access" {
  name        = "parameter_store_access"
  description = "Policy to allow ECS tasks to access specific parameters in Parameter Store"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/DJANGO_SECRET_KEY",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_ACCESS_KEY_ID",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_RDS_DB_NAME",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_RDS_HOST",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_RDS_PASSWORD",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_RDS_USERNAME",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_SECRET_ACCESS_KEY",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_STORAGE_BUCKET_NAME",
        "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/TECHRONOMICON_IP"
      ]
    }
  ]
}
EOF
}

# Attach the IAM policy to the role
resource "aws_iam_role_policy_attachment" "ecs_role_parameter_store_access" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.parameter_store_access.arn
}

# Create copy to copy files from the cloudwatch-logs-config bucket
resource "aws_iam_policy" "cloudwatch_logs_config_copy_policy" {
  name        = "cloudwatch_logs_config_s3_copy"
  description = "IAM policy to allow copying files from the cloudwatch-logs-config-8473324 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:CopyObject"
        ]
        Resource = [
	  "arn:aws:s3:::${var.CLOUDWATCH_LOGS_CONFIG_BUCKET_NAME}",
          "arn:aws:s3:::${var.CLOUDWATCH_LOGS_CONFIG_BUCKET_NAME}/*"
        ]
      }
    ]
  })
}

# Attach S3CopyPolicy to the role
resource "aws_iam_role_policy_attachment" "ecs_role_cloudwatch_logs_config_copy_policy" {
  role = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_config_copy_policy.arn
}

# Create IAM role
resource "aws_iam_role" "ecs_role" {
  name = "ecs_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach AmazonEC2ContainerServiceforEC2Role managed policy
resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Create policy for EC2 to interact with Cloudwatch logs
resource "aws_iam_policy" "cwlogs_policy" {
  name        = "CWLogsPolicy"
  description = "A policy that allows sufficient permissions for CloudWatch logs and metric data."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = "cloudwatch:PutMetricData",
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}


# Attach EC2 Cloudwatch policy to role
resource "aws_iam_role_policy_attachment" "cwlogs_policy_attachment" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.cwlogs_policy.arn
}


# Create IAM instance profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_role.name
}

# Setup Github as an identity provider
resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c"]
}

# Create role for Github workflow to assume
resource "aws_iam_role" "github-actions-role" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.default.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
	  },
	  StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:lukejcollins/techronomicon-infra:*"
          }
        }
      }
    ]
  })
}

# Attach AdministratorAccess policy to Github Actions role
resource "aws_iam_role_policy_attachment" "github-actions-role-attachement" {
  role       = aws_iam_role.github-actions-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
