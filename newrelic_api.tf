resource "aws_iam_role" "newrelic_api_read_access" {
  name        = "TF-NewRelic-API-Polling-Role-${data.aws_region.current.name}"
  description = "Role to allow NewRelic to read API data"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::754728514883:root"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : var.nr_account
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "newrelic_api_read_access" {
  policy_arn = data.aws_iam_policy.ReadOnlyAccess.arn
  role       = aws_iam_role.newrelic_api_read_access.name
}
