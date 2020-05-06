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

output "dashboard-url" {
  value = "https://${data.aws_region.self.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.self.name}#dashboards:name=${aws_cloudwatch_dashboard.remo.dashboard_name};accountId=${data.aws_caller_identity.self.account_id}"
}
