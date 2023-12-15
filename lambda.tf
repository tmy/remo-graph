#
# Nature Remo の情報を Lambda 関数で定期的に取得する
#

resource "aws_lambda_function" "app" {
  function_name    = var.app_name
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.app.output_path
  source_code_hash = data.archive_file.app.output_base64sha256

  # 関数が利用する AWS リソースの情報は環境変数で注入する
  environment {
    variables = {
      API_KEY                   = var.nature_remo_api_key
      CLOUDWATCH_DASHBOARD_NAME = aws_cloudwatch_dashboard.remo.dashboard_name
      DELIVERY_STREAM_NAME      = aws_kinesis_firehose_delivery_stream.history.name
    }
  }

  tags = {
    AppName = var.app_name
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda # 先にロググループを作っておく
  ]
}

data "archive_file" "app" {
  type        = "zip"
  output_path = "app.zip"

  source {
    content  = file("lambda/index.js")
    filename = "index.js"
  }
  source {
    content  = file("lambda/remo.js")
    filename = "remo.js"
  }
  source {
    content  = file("lambda/cloudwatch_metric.js")
    filename = "cloudwatch_metric.js"
  }
  source {
    content  = file("lambda/cloudwatch_dashboard.js")
    filename = "cloudwatch_dashboard.js"
  }
  source {
    content  = file("lambda/firehose.js")
    filename = "firehose.js"
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.app_name}"
  retention_in_days = 30
}

# 5 分毎に CloudWatch イベントを発生させる
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "lambda-${var.app_name}"
  description         = "Launch lambda function '${var.app_name}'"
  schedule_expression = "rate(5 minutes)"

  tags = {
    AppName = var.app_name
  }
}

# イベントが発生したら Lambda 関数を起動する
resource "aws_cloudwatch_event_target" "schedule" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda-${var.app_name}"
  arn       = aws_lambda_function.app.arn
}

# イベントに Lambda 関数起動を許可
resource "aws_lambda_permission" "schedule" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
  name_prefix        = "${var.app_name}-lambda-"

  tags = {
    AppName = var.app_name
  }
}

# Lambda 関数に与える権限
data "aws_iam_policy_document" "lambda" {
  # ログ出力を許可
  statement {
    sid = "Log"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.lambda.arn
    ]
  }
  # CloudWatch メトリック出力を許可
  statement {
    sid = "Metrics"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }
  # CloudWatch Dashboard の更新を許可
  statement {
    sid = "Dashboard"
    actions = [
      "cloudwatch:PutDashboard"
    ]
    resources = [
      aws_cloudwatch_dashboard.remo.dashboard_arn
    ]
  }
  # Kinesis Firehose への出力を許可
  statement {
    sid = "Firehose"
    actions = [
      "firehose:PutRecordBatch"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.history.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda" {
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}
