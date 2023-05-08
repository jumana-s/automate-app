terraform {
  backend "s3" {
    bucket         = "tf-statefile-dev-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/tf-bucket-key"
    dynamodb_table = "tf-state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      env     = var.env
      project = "simple-app"
      creator = "terraform"
    }
  }
}
