include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//cluster_apps"
}

inputs = {
  env            = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals.environment
  cluster_name   = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals.environment
  namespace_name = "simple-app"
}
