# Create an AWS CloudWatch Log Group named "techronomicon"
resource "aws_cloudwatch_log_group" "example" {
  name = "techronomicon"
}

resource "aws_cloudwatch_log_group" "error_log" {
  name              = "error.log"
  retention_in_days = 14
}
