#
# グラフを CloudWatch Dashboard で見られるようにする
#

resource "aws_cloudwatch_dashboard" "remo" {
  # 表示内容は Lambda で動的に更新する
  dashboard_body = jsonencode({
    widgets = []
  })
  dashboard_name = var.app_name

  lifecycle {
    ignore_changes = [dashboard_body]
  }
}
