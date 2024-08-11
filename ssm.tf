# Define variables for SSM
locals {
  techronomicon_parameters = {
    TECHRONOMICON_ACCESS_KEY_ID     = var.TECHRONOMICON_ACCESS_KEY_ID
    TECHRONOMICON_SECRET_ACCESS_KEY = var.TECHRONOMICON_SECRET_ACCESS_KEY
    TECHRONOMICON_RDS_USERNAME      = var.DB_USERNAME
    TECHRONOMICON_RDS_PASSWORD      = var.DB_PASSWORD
    TECHRONOMICON_STORAGE_BUCKET_NAME = var.TECHRONOMICON_STORAGE_BUCKET_NAME
    DJANGO_SECRET_KEY               = var.DJANGO_SECRET_KEY
    TECHRONOMICON_RDS_DB_NAME       = var.TECHRONOMICON_RDS_DB_NAME
    TECHRONOMICON_RDS_HOST          = aws_db_instance.db.address
  }
}

# Create parameters in SSM
resource "aws_ssm_parameter" "techronomicon_parameters" {
  for_each = local.techronomicon_parameters

  name  = "/${each.key}"
  type  = "String"
  value = each.value
}

# Store EC2 IP in Parameter Store
resource "aws_ssm_parameter" "public_ip" {
  name        = "/TECHRONOMICON_IP"
  description = "Public IP of the EC2 instance"
  type        = "String"
  value       = aws_instance.example.public_ip
}

# Store EC2 Instance ID in Parameter Store
resource "aws_ssm_parameter" "instance_id" {
  name        = "INSTANCE_ID"
  description = "Instance ID of the EC2 instance"
  type        = "String"
  value       = aws_instance.example.id
}
