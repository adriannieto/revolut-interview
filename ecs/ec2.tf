# Allow public access 
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
resource "aws_security_group" "ecs_lb" {
  name        = "${local.resource_name_prefix}-ecs-lb"
  description = "${local.resource_name_prefix}-ecs-lb"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow traffic from LB to container app port"
    protocol    = "tcp"
    from_port   = var.app_lb_port
    to_port     = var.app_lb_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow trafic to our vpc only in the ecs service port"
    protocol    = "tcp"
    from_port   = var.app_ecs_service_port
    to_port     = var.app_ecs_service_port
    cidr_blocks = aws_subnet.private[*].cidr_block
  }
}

# Allow all traffic to egress
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "ecs_task" {
  name        = "${local.resource_name_prefix}-ecs-task"
  description = "${local.resource_name_prefix}-ecs-task"

  vpc_id = aws_vpc.main.id

  ingress {
    description     = "Allow incoming traffic from lb in ecs service port"
    protocol        = "tcp"
    from_port       = var.app_ecs_service_port
    to_port         = var.app_ecs_service_port
    security_groups = [aws_security_group.ecs_lb.id]
  }

  egress {
    description = "Allow all outgoing traffic to vpc"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Exposed to the internet on purpose
#tfsec:ignore:aws-elb-alb-not-public
resource "aws_alb" "ecs" {
  name                       = "${local.resource_name_prefix}-ecs"
  subnets                    = aws_subnet.public[*].id
  security_groups            = [aws_security_group.ecs_lb.id]
  internal                   = false
  drop_invalid_header_fields = true

}

resource "aws_alb_target_group" "app" {
  name        = "${local.resource_name_prefix}-ecs-app"
  port        = var.app_ecs_service_port
  protocol    = var.app_ecs_service_protocol
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = aws_alb.ecs.id
  port              = var.app_lb_port
  protocol          = var.app_lb_protocol

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}