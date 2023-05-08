module "pipeline_iam" {
  source = "./modules/pipelines-iam"

  pipeline_user_name = "github"
}

module "s3_statefile" {
  source = "./modules/s3-statefile"

  env = var.env
}
