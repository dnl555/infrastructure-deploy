resource "aws_lb_target_group" "api-tg" {
  name = "api-tg"

  vpc_id   = aws_vpc.main.id
  protocol = "HTTP"
  port     = 80

  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb" "api" {
  name               = "api-alb"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = 300

  security_groups                  = [aws_security_group.alb-sg.id]
  subnets                          = aws_subnet.public_subnets.*.id
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = true
  enable_http2               = true
}

# don't need this for now
# resource "aws_lb_listener" "api-https" {
#   load_balancer_arn = aws_lb.api.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = aws_acm_certificate.wildcard_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.api-tg.arn
#   }
# }

resource "aws_lb_listener" "api-http" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-tg.arn
  }
}
