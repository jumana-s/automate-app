resource "aws_iam_group" "pipelines" {
  name = var.group_name
}

resource "aws_iam_policy" "policy" {
  name        = "pipeline_policy"
  description = "Gives pipeline admin powers"

  # jsonencode converts Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = aws_iam_group.pipelines.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user" "github_pipeline_user" {
  name = var.pipeline_user_name
}

resource "aws_iam_group_membership" "membership" {
  name = "${var.pipeline_user_name}-user-membership"

  users = [aws_iam_user.github_pipeline_user.name]

  group = aws_iam_group.pipelines.name
}
