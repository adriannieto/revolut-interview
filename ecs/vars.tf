variable "region" {
  description = "AWS Region to use check https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions"
  type        = string
}

variable "availability_zones_enabled" {
  description = "Number of availability zones to enable, it depends on the region, check https://docs.aws.amazon.com/en_en/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = number

  validation {
    condition     = var.availability_zones_enabled > 0 && var.availability_zones_enabled <= 3
    error_message = "The number of AZ should be between 0 and 3 (included)"
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR, we recommend to use greater or equal to /24"
  type = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name name"
  type        = string
}


variable "app_name" {
  description = "Application name"
  type        = string
}

variable "app_lb_port" {
  description = "Load balancer external facing port"
  type        = number
}

variable "app_lb_protocol" {
  description = "Load balancer external facing protocol protocol"
  type        = string

  validation {
    condition     = can(regex("^(HTTP|HTTPS)$", var.app_lb_protocol))
    error_message = "Valid options are HTTP or HTTPS."
  }
}

variable "app_ecs_service_port" {
  description = "ECS Service side app port"
  type        = number
}

variable "app_ecs_service_protocol" {
  description = "ECS Service side app protocol"
  type        = string

  validation {
    condition     = can(regex("^(HTTP|HTTPS)$", var.app_ecs_service_protocol))
    error_message = "Valid options are HTTP or HTTPS."
  }
}

variable "app_ecs_task_container_image" {
  description = "ECS task container image"
  type        = string
}

variable "app_ecs_container_registry_username" {
  description = "ECS task container image registry username"
  type        = string
  sensitive = true
}

variable "app_ecs_container_registry_password" {
  description = "ECS task container image registry password"
  type        = string
  sensitive = true
}
