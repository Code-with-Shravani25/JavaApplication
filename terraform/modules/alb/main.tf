resource "aws_lb_target_group" "this" {

  name = "${var.project_name}-tg"

  port = 8080

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {
    path = "/health"

    protocol = "HTTP"

    matcher = "200"
  }
}
resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.this.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.this.arn
  }
}
