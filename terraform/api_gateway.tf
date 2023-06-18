resource "aws_api_gateway_rest_api" "api" {
  name           = "personal-website-api"
  api_key_source = "HEADER"
}

resource "aws_lambda_permission" "contact_lambda_api_gateway_permission" {
  function_name = local.contact_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

  depends_on = [aws_lambda_function.contact_lambda]
}

resource "aws_api_gateway_resource" "api_contact_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_contact_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api_contact_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options_api_integration" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.api_contact_resource.id
  http_method      = aws_api_gateway_method.options_method.http_method
  content_handling = "CONVERT_TO_TEXT"

  type = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_integration_response" "options_api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api_contact_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://www.rohinchopra.com'"
  }
}

resource "aws_api_gateway_method" "api_contact_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.api_contact_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "api_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api_contact_resource.id
  http_method             = aws_api_gateway_method.api_contact_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.api_stage

  depends_on = [aws_api_gateway_integration.api_lambda_integration]
}

resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name = "personal-website-api-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = var.api_stage
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "personal-website-api-key"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key_notification" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}

resource "aws_api_gateway_domain_name" "api_domain_name" {
  domain_name     = "api.rohinchopra.com"
  certificate_arn = aws_acm_certificate_validation.api_certificate_validation.certificate_arn
  security_policy = "TLS_1_2"
}

resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  domain_name = aws_acm_certificate.api_certificate.domain_name
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = var.api_stage

  depends_on = [aws_api_gateway_domain_name.api_domain_name]
}
