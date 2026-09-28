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