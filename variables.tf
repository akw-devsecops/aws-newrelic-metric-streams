variable "nr_account" {
  type        = string
  description = "The account id from the target NewRelic account."
}

variable "nr_license_key" {
  type        = string
  description = "The NewRelic ingest license key."
}

variable "include_resource" {
  type        = list(string)
  description = "List of included resources. If you specify this parameter, the stream sends only the metrics from the resources that you specify here. List of available namespaces: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html"
  default     = []
}

variable "tags" {
  type = map(string)
}
