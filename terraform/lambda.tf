data "archive_file" "contact_lambda_package" {
  type        = "zip"
  source_file = "../.esbuild/index.js"
  output_path = local.contact_lambda_function_zip_name
}

resource "aws_lambda_function" "contact_lambda" {
  function_name    = local.contact_lambda_function_name
  filename         = local.contact_lambda_function_zip_name
  source_code_hash = data.archive_file.contact_lambda_package.output_base64sha256
  handler          = "index.contactHandler"
  runtime          = "nodejs16.x"
  publish          = "true"
  role             = aws_iam_role.contact_lambda_role.arn
  environment {
    variables = {
      ADMIN_EMAIL                = var.admin_email
      NO_REPLY_EMAIL             = var.no_reply_email
      NOTIFY_EMAIL_TEMPLATE_NAME = aws_ses_template.contact_notify_template.name
      REPLY_EMAIL_TEMPLATE_NAME  = aws_ses_template.contact_reply_template.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.contact_lambda_log_group]

  tags = {
    STAGE = var.api_stage
  }
}
