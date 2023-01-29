data "archive_file" "efs-file-creator" {
  source_file = "${path.module}/code/lambda.py"
  output_path = "lambda.py.zip"
  type        = "zip"
}

data "aws_subnet" "subnet" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

resource "aws_security_group" "lambda_security_group" {
  vpc_id = var.lambda_vpc_id

  ingress {
    from_port   = 2049
    protocol    = "tcp"
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 2049
    protocol    = "tcp"
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "lambda_function" {
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  package_type     = var.lambda_package_type
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_function_role.arn
  filename         = data.archive_file.efs-file-creator.output_path
  source_code_hash = filebase64sha256(data.archive_file.efs-file-creator.source_file)

  file_system_config {
    arn              = var.lambda_efs_access_point_arn
    local_mount_path = "/mnt/lambda"
  }

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [for s in data.aws_subnet.subnet : s.id]
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }

  tags = {
    Name = var.lambda_function_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_role_policy_attachment" {
  role       = aws_iam_role.lambda_function_role.name
  policy_arn = aws_iam_policy.lambda_function_managed_role.arn
}

resource "aws_iam_role" "lambda_function_role" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_function_assume_role_policy_document.json
}

resource "aws_iam_policy" "lambda_function_managed_role" {
  name   = var.lambda_function_managed_policy_name
  policy = data.aws_iam_policy_document.lambda_function_efs_access_policy_document.json
}

data "aws_iam_policy_document" "lambda_function_assume_role_policy_document" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}


data "aws_iam_policy_document" "lambda_function_efs_access_policy_document" {
  dynamic "statement" {
    for_each = var.lambda_function_managed_policy_statements
    iterator = statement
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}