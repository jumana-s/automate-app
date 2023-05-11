include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//cluster_apps"
}

inputs = {
  env            = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.environment
  cluster_name   = "${read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.environment}-cluster"
  namespace_name = "simple-app"
  ecr_name       = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.ecr_name
  region         = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.region
}
