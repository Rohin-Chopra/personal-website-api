data "aws_iam_policy_document" "contact_lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "contact_lambda_role" {
  name               = "contact-lambda-${var.api_stage}-${var.aws_region}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.contact_lambda_assume_role_policy.json

  tags = {
    STAGE = var.api_stage
  }
}

data "aws_iam_policy_document" "cloudwatch_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]

    resources = [aws_cloudwatch_log_group.contact_lambda_log_group.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.contact_lambda_log_group.arn}:*"]
  }
}

resource "aws_iam_role_policy" "contact_lambda_cloudwatch_policy" {
  name   = "contact-lambda-${var.api_stage}-cloudwatch-policy"
  policy = data.aws_iam_policy_document.cloudwatch_role_policy_document.json
  role   = aws_iam_role.contact_lambda_role.id
}

data "aws_iam_policy_document" "contact_lambda_ses_policy_document" {
  statement {
    effect = "Allow"

    actions = ["ses:SendTemplatedEmail"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "contact_lambda_ses_policy" {
  name   = "contact-lambda-${var.api_stage}-ses-policy"
  policy = data.aws_iam_policy_document.contact_lambda_ses_policy_document.json
  role   = aws_iam_role.contact_lambda_role.id
}
