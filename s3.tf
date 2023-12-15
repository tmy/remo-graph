#
# データ履歴置き場
#

resource "aws_s3_bucket" "history" {
  bucket_prefix = "${var.app_name}-history-"

  tags = {
    AppName = var.app_name
  }
}

resource "aws_s3_bucket_versioning" "history" {
  bucket = aws_s3_bucket.history.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# パブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "history" {
  bucket                  = aws_s3_bucket.history.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

import {
  to = aws_s3_bucket_versioning.history
  id = aws_s3_bucket.history.bucket
}
