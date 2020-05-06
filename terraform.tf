terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = "~> 2.48"
}

provider "archive" {
  version = "~> 1.3"
}

data "aws_caller_identity" "self" {}

data "aws_region" "self" {}
