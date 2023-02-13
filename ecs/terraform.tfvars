
region                     = "eu-west-1"
availability_zones_enabled = 2

vpc_cidr = "172.17.0.0/16"

environment              = "prod"
project                  = "revolut"
app_name                 = "app"
app_lb_port              = 80
app_lb_protocol          = "HTTP"
app_ecs_service_port     = 8000
app_ecs_service_protocol = "HTTP"