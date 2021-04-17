### CREATE ALB

resource "aws_lb" "nginx" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets            = [aws_subnet.PublicA.id, aws_subnet.PublicB.id]
}

### CREATE REDIRECT FROM 80

resource "aws_lb_listener" "nginx_80" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }
}

### LIST ON 443 (HTTP, BECAUSE NO CERTIFCATE;-) )

resource "aws_lb_listener" "nginx_443" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "443"
  protocol          = "HTTP"
  #ssl_policy        = ""
  #certificate_arn   = ""

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

### CREATE TARGET GROUP

resource "aws_lb_target_group" "nginx" {
  name        = "nginx-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}

### ATTACH TO ASG

resource "aws_autoscaling_attachment" "asg_attachment_nginx" {
  autoscaling_group_name = aws_autoscaling_group.nginx.id
  alb_target_group_arn = aws_lb_target_group.nginx.arn
}