include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//cluster"
}

inputs = {
  cluster_name = "${read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.environment}-cluster"
}

retryable_errors = [
  "(?s).*The configmap.*auth.*does not exist.* " 
]
