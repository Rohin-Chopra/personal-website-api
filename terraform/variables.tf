variable "aws_region" {
  type        = string
  description = "Region where AWS resources are going to be deployed"
}

variable "contact_lambda_function_stage" {
  type        = string
  description = "Stage/env for the contact lambda function"
}

variable "no_reply_email" {
  type        = string
  description = "The no reply email address that the API is going to send emails from"
}

variable "admin_email" {
  type        = string
  description = "The email address that the API will notify of a form submission"
}
