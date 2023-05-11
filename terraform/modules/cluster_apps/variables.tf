variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "namespace_name" {
  type        = string
  description = "Namespace name"
}

variable "ecr_name" {
  type        = string
  description = "ECR repo name"
}

variable "image_tag" {
  type        = string
  description = "Image to use's tag"
  default     = "latest"
}

variable "region" {
  type        = string
  description = "Region name"
}
