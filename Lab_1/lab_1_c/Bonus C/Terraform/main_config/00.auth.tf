terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }

  }
  required_version = ">1.10"
}

provider "aws" {
  alias  = "aws_1"
  region = "us-east-1"
}
