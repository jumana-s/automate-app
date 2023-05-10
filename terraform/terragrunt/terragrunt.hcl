locals {
  vars       = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env_name   = local.vars.locals.environment
  aws_region = local.vars.locals.region
}

generate "versions" {
  path = "versions.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
    default_tags {
    tags = {
      env     = "dev"
      project = "simple-app"
      creator = "terraform"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "${local.env_name}-statefile-bucket"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "tf-state-lock"
  }
}
