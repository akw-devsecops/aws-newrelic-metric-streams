data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
