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

# Create IAM instance profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_role.name
}
