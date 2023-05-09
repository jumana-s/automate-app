include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//pipelines-iam"
}

inputs = {
  pipeline_user_name = "github"
}
