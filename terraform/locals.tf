locals {
  build_directory_path = "${path.module}/build"

  contact_lambda_function_name     = "contact-lambda"
  contact_lambda_function_zip_name = "${local.build_directory_path}/${local.contact_lambda_function_name}-package.zip"
}
