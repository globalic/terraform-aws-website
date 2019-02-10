variable "zone_id" {}
variable "name" {}

variable "fqdn" {}

variable "origin_id" {}
variable "origin_access_identity" {}

variable "cloudfront_comment" {}

variable "cloudfront_logs_bucket" {}

variable "cloudfront_logs_prefix" {
  default = "logs/www"
}

variable "price_class" {
  default = "PriceClass_100"
}

variable "index_document" {
  default = ""
}

variable "error_document" {
  default = ""
}

variable "routing_rules" {
  default = ""
}

variable "s3_bucket_name" {}

variable "s3_logs_bucket" {}

variable "s3_logs_prefix" {
  default = "logs/s3"
}
