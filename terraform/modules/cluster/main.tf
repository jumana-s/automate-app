resource "aws_kms_key" "log_key" {
  description             = "For Cloudwatch Logs"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "${var.env}-cluster-logs"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.env}-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.log_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.logs.name
      }
    }
  }
}
