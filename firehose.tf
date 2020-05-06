#
# データを Kinesis Firehose 経由で S3 に保存する
#

resource "aws_kinesis_firehose_delivery_stream" "history" {
  name        = "${var.app_name}-history"
  destination = "extended_s3"

  extended_s3_configuration {
    bucket_arn          = aws_s3_bucket.history.arn
    role_arn            = aws_iam_role.firehose.arn
    prefix              = "data/!{timestamp:'year='yyyy'/month='MM'/day='dd}/" # Athena でパーティションが作れる形式
    error_output_prefix = "error/!{timestamp:'year='yyyy'/month='MM'/day='dd}/!{firehose:error-output-type}"
    buffer_size         = 5
    buffer_interval     = 900 # 最大値
  }

  tags = {
    AppName = var.app_name
  }

  depends_on = [
    aws_cloudwatch_log_group.firehose # 先にロググループを作っておく
  ]
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesisfirehose/${var.app_name}-history"
  retention_in_days = 30
}

resource "aws_iam_role" "firehose" {
  assume_role_policy = data.aws_iam_policy_document.firehose-assume-role-policy.json
  name_prefix        = "${var.app_name}-firehose-"

  tags = {
    AppName = var.app_name
  }
}

data "aws_iam_policy_document" "firehose-assume-role-policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [data.aws_caller_identity.self.account_id]
    }
  }
}

resource "aws_iam_role_policy" "firehose" {
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}

data "aws_iam_policy_document" "firehose" {
  statement {
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.history.arn,
      "${aws_s3_bucket.history.arn}/*",
    ]
  }
  statement {
    actions = [
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.firehose.arn}:log-stream:*"
    ]
  }
}
