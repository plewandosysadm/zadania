### AUTOSCALING TEMPLATE

resource "aws_launch_configuration" "nginx" {
  name_prefix   = "nginx"
  image_id      = "ami-0988ecb63a00edc61"
  instance_type = "t3.nano"
  security_groups = [aws_security_group.default.id]

  lifecycle {
    create_before_destroy = true
  }
}

### ASG GROUP

resource "aws_autoscaling_group" "nginx" {
  desired_capacity   = 3
  max_size           = 6
  min_size           = 3
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  vpc_zone_identifier = [aws_subnet.PrivateA.id, aws_subnet.PrivateB.id]
  launch_configuration = aws_launch_configuration.nginx.name
}

### ASG POLICIES

resource "aws_autoscaling_policy" "example-cpu-policy" {
    name = "example-cpu-policy"
    autoscaling_group_name = aws_autoscaling_group.nginx.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
    alarm_name = "example-cpu-alarm"
    alarm_description = "example-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "50"
    dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.nginx.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.example-cpu-policy.arn]
}

resource "aws_autoscaling_policy" "example-cpu-policy-scaledown" {
    name = "example-cpu-policy-scaledown"
    autoscaling_group_name = aws_autoscaling_group.nginx.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
    alarm_name = "example-cpu-alarm-scaledown"
    alarm_description = "example-cpu-alarm-scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "5"
    dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.nginx.name
    }
    actions_enabled = true
    alarm_actions = [aws_autoscaling_policy.example-cpu-policy-scaledown.arn]
}
