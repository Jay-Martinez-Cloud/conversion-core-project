#######################################
# CloudWatch Alarms (Phase 3B)
#######################################

# CPU alarm (native EC2 metric)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  alarm_description   = "High CPU on SQL host"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.sql_host.id
  }
}

# Memory alarm (CloudWatch Agent metric)
resource "aws_cloudwatch_metric_alarm" "mem_high" {
  alarm_name          = "${local.name_prefix}-mem-used-high"
  alarm_description   = "High memory usage on SQL host"
  namespace           = "EPLConversion/EC2"
  metric_name         = "mem_used_percent"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = 85
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.sql_host.id
  }
}

# Disk alarm (CloudWatch Agent metric)
resource "aws_cloudwatch_metric_alarm" "disk_high" {
  alarm_name          = "${local.name_prefix}-disk-used-high"
  alarm_description   = "High disk usage on SQL host"
  namespace           = "EPLConversion/EC2"
  metric_name         = "disk_used_percent"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    InstanceId = aws_instance.sql_host.id
    path       = "/"
    fstype     = "xfs"
    device     = "nvme0n1p1"
  }
}
