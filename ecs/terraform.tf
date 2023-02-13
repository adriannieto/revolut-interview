terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }

  backend "s3" {
    bucket = "adrian-nieto-revolut-interview"
    key    = "prod-revolut-interview-app.state"
    region = "eu-west-1"
  }

}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      environment = var.environment
      app         = var.app_name
      project     = "ecs"
      created_by  = "terraform"
    }
  }
}