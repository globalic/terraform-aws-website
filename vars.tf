variable "zone_id" {}
variable "name" {}

variable "fqdn" {}

variable "acm_tags" {
  type    = "map"
  default = {}
}

variable "origin_id" {}
variable "origin_access_identity" {}

variable "cloudfront_comment" {}

variable "cloudfront_origin_read_timeout" {
  default = 5
}

variable "cloudfront_origin_ssl_protocols" {
  type    = "list"
  default = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
}

variable "cloudfront_tags" {
  type    = "map"
  default = {}
}

variable "cloudfront_logs_bucket" {}

variable "cloudfront_logs_prefix" {
  default = ""
}

variable "cloudfront_forwarded_query_strings" {
  default = "false"
}

variable "cloudfront_404_response_code" {
  default = "404"
}

variable "cloudfront_404_response_path" {
  default = ""
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

variable "s3_tags" {
  type    = "map"
  default = {}
}

variable "s3_bucket_name" {}

variable "s3_logs_bucket" {}

variable "s3_logs_prefix" {
  default = "logs/s3"
}

variable "s3_cors" {
  type    = "list"
  default = []
}

variable "s3_cors_allowed_methods" {
  type    = "list"
  default = []
}

variable "s3_cors_allowed_origins" {
  type    = "list"
  default = []
}
