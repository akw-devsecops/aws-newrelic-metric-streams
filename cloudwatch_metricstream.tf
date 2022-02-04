resource "aws_cloudwatch_metric_stream" "newrelic_stream" {
  name          = "TF-NewRelic-Metric-Stream"
  role_arn      = aws_iam_role.newrelic_cloudwatch_firehose_put.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.newrelic_stream.arn
  output_format = "opentelemetry0.7"

  dynamic "include_filter" {
    for_each = var.include_resource
    content {
      namespace = include_filter.value
    }
  }
}

resource "aws_iam_role" "newrelic_cloudwatch_firehose_put" {
  name        = "TF-NewRelic-Metric-Stream-Service-Role-${data.aws_region.current.name}"
  description = "Role to allow a metric stream put metrics into a firehose"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "streams.metrics.cloudwatch.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "newrelic_cloudwatch_firehose_put" {
  name = "TF-MetricStream-FirehoseAccess-${data.aws_region.current.name}"
  role = aws_iam_role.newrelic_cloudwatch_firehose_put.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        "Resource" : [
          aws_kinesis_firehose_delivery_stream.newrelic_stream.arn
        ],
        "Effect" : "Allow"
      }
    ]
  })
}
