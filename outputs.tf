output "s3_bucket_arn" {
  value = "${aws_s3_bucket.main.arn}"
}

output "domain_name" {
  value = "${aws_cloudfront_distribution.main.domain_name}"
}

output "hosted_zone_id" {
  value = "${aws_cloudfront_distribution.main.hosted_zone_id}"
}
