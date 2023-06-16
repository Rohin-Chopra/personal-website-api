resource "aws_api_gateway_rest_api" "personal_website_api" {
  name           = "personal-website-api"
  api_key_source = "HEADER"
}

resource "aws_lambda_permission" "contact_lambda_api_gateway_permission" {
  function_name = local.contact_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.personal_website_api.execution_arn}/*/*"

  depends_on = [aws_lambda_function.contact_lambda]
}

resource "aws_api_gateway_resource" "personal_website_api_contact_resource" {
  rest_api_id = aws_api_gateway_rest_api.personal_website_api.id
  parent_id   = aws_api_gateway_rest_api.personal_website_api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "personal_website_api_contact_method" {
  rest_api_id      = aws_api_gateway_rest_api.personal_website_api.id
  resource_id      = aws_api_gateway_resource.personal_website_api_contact_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "personal_website_api_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.personal_website_api.id
  resource_id             = aws_api_gateway_resource.personal_website_api_contact_resource.id
  http_method             = aws_api_gateway_method.personal_website_api_contact_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "personal_website_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.personal_website_api.id
  stage_name  = "dev"

  depends_on = [aws_api_gateway_integration.personal_website_api_lambda_integration]
}

resource "aws_api_gateway_usage_plan" "personal_website_api_usage_plan" {
  name = "personal-website-api-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.personal_website_api.id
    stage  = "dev"
  }
}

resource "aws_api_gateway_api_key" "personal_website_api_key" {
  name = "personal-website-api-key"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key_notification" {
  key_id        = aws_api_gateway_api_key.personal_website_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.personal_website_api_usage_plan.id
}

