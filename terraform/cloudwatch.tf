resource "aws_cloudwatch_log_group" "contact_lambda_log_group" {
  name = "/aws/lambda/${local.contact_lambda_function_name}"
}
