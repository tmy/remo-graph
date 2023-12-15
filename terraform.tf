terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }
}

provider "aws" {
}

provider "archive" {
}

data "aws_caller_identity" "self" {}

data "aws_region" "self" {}
