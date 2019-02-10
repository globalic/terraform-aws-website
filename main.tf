/**
 * Creates a static website.
 *
 * Creates the following resources:
 *
 * * ACM Certificate
 * * CloudFront Distribution
 * * Route53 Records
 *

 * ## Usage
 *
 * ```hcl
 * module "website" {
 *   source = "spatialcurrent/website/aws"
 *
 *   origin_id            = "${var.origin_id}"
 * }
 * ```
 */

# https://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html
resource "aws_acm_certificate" "main" {
  provider = "aws.us-east-1"

  domain_name       = "${var.fqdn}"
  validation_method = "DNS"

  tags {}

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.zone_id}"
  records = ["${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  provider = "aws.us-east-1"

  certificate_arn         = "${aws_acm_certificate.main.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }

  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
    routing_rules  = "${var.routing_rules}"
  }

  logging {
    target_bucket = "${var.s3_logs_bucket}"
    target_prefix = "${var.s3_logs_prefix}"
  }

  tags {
    Name = "${var.s3_bucket_name}"
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.main.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = "${aws_s3_bucket.main.id}"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = "${aws_s3_bucket.main.website_endpoint}"
    origin_id   = "${var.origin_id}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 5
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.cloudfront_comment}"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${var.cloudfront_logs_bucket}"
    prefix          = "${var.cloudfront_logs_prefix}"
  }

  aliases = ["${var.fqdn}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    target_origin_id = "${var.origin_id}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "${var.price_class}"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Name = "${var.name}"
  }

  viewer_certificate {
    acm_certificate_arn            = "${aws_acm_certificate.main.arn}"
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${var.zone_id}"
  name    = "${var.fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}
