include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//ecr"
}

inputs = {
  name = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.ecr_name
}
