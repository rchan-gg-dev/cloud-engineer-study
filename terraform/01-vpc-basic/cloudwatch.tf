resource "aws_cloudwatch_metric_alarm" "public_ec2_cpu_high" {
  alarm_name          = "terraform-study-public-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  period      = 300
  statistic   = "Average"
  threshold   = 5

  dimensions = {
    InstanceId = aws_instance.public.id
  }

  treat_missing_data = "notBreaching"
  actions_enabled    = false
}

resource "aws_cloudwatch_log_group" "httpd_access" {
  name              = "/terraform-study/httpd/access"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "httpd_error" {
  name              = "/terraform-study/httpd/error"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_metric_filter" "httpd_error" {
  name           = "terraform-study-httpd-error"
  log_group_name = aws_cloudwatch_log_group.httpd_error.name
  pattern        = "AH01264"

  metric_transformation {
    name      = "HttpdErrorCount"
    namespace = "TerraformStudy/Httpd"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "httpd_error" {
  alarm_name          = "terraform-study-httpd-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1

  metric_name = "HttpdErrorCount"
  namespace   = "TerraformStudy/Httpd"
  period      = 60
  statistic   = "Sum"
  threshold   = 1

  treat_missing_data = "notBreaching"
  actions_enabled    = false
}