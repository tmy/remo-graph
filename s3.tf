#
# データ履歴置き場
#

resource "aws_s3_bucket" "history" {
  bucket_prefix = "${var.app_name}-history-"

  versioning {
    enabled = true
  }

  tags = {
    AppName = var.app_name
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
