include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//cluster"
}

inputs = {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals.environment
}
