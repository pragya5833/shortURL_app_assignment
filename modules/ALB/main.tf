resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Host not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }
}

resource "aws_lb_target_group" "main" {
  name     = "main-target-group"
  port        = 31336 
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/health"
    port                = "31336"                 # Kubelet health check port
    protocol            = "HTTP"
    interval            = 30
    timeout             = 20
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_route53_record" "alb_alias" {
  zone_id = var.route53_zone_id
  name    = "api.deeplink.in"
  type    = "A"

  alias {
    name                   = aws_lb.frontend_alb.dns_name
    zone_id                = aws_lb.frontend_alb.zone_id
    evaluate_target_health = true
  }
}
# resource "aws_route53_record" "alb_alias" {
#   for_each = toset(var.host_headers)
  
#   zone_id = var.route53_zone_id
#   name    = each.value
#   type    = "A"

#   alias {
#     name                   = aws_lb.frontend_alb.dns_name
#     zone_id                = aws_lb.frontend_alb.zone_id
#     evaluate_target_health = true
#   }
# }
resource "aws_autoscaling_attachment" "asg_tg_attachment" {
  autoscaling_group_name = data.aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
  lb_target_group_arn   = aws_lb_target_group.main.arn
}

# Ingress rule to allow traffic from the ALB security group on port 31336
resource "aws_security_group_rule" "allow_alb_to_node_group" {
  type                     = "ingress"
  from_port                = 31336
  to_port                  = 31336
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.worker_node_sg.id  
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "Allow traffic from ALB on port 31336"
}

