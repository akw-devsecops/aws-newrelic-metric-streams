resource "aws_kinesis_firehose_delivery_stream" "newrelic_stream" {
  name        = "TF-NewRelic-Delivery-Stream"
  destination = "http_endpoint"

  s3_configuration {
    bucket_arn         = aws_s3_bucket.newrelic_firehose_events.arn
    role_arn           = aws_iam_role.newrelic_firehose_s3access.arn
    compression_format = "GZIP"
  }

  http_endpoint_configuration {
    name               = "New Relic"
    url                = "https://aws-api.newrelic.com/cloudwatch-metrics/v1"
    access_key         = var.nr_license_key
    role_arn           = aws_iam_role.newrelic_firehose_s3access.arn
    s3_backup_mode     = "FailedDataOnly"
    retry_duration     = 60
    buffering_interval = 60
    buffering_size     = 1

    request_configuration {
      content_encoding = "GZIP"
    }
  }

  tags = var.tags
}

resource "aws_iam_role" "newrelic_firehose_s3access" {
  name        = "TF-NewRelic-Delivery-Stream-Service-Role-${data.aws_region.current.name}"
  description = "Role to allow firehose stream put events into S3 backup bucket"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "firehose.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "newrelic_firehose_s3access" {
  name = "TF-Firehose-S3Access-${data.aws_region.current.name}"
  role = aws_iam_role.newrelic_firehose_s3access.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        "Resource" : [
          aws_s3_bucket.newrelic_firehose_events.arn,
          "${aws_s3_bucket.newrelic_firehose_events.arn}/*"
        ],
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_s3_bucket" "newrelic_firehose_events" {
  bucket = "tf-newrelic-firehose-event-${data.aws_region.current.name}-${var.nr_account}-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "newrelic_firehose_events" {
  bucket = aws_s3_bucket.newrelic_firehose_events.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
