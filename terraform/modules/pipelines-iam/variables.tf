variable "group_name" {
  type        = string
  default     = "pipelines"
  description = "Name for IAM group that will have pipeline IAM users"
}

variable "pipeline_user_name" {
  type        = string
  description = "Name for IAM user that will be used in pipeline."
}
