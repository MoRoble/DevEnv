variable "common-tags" {
  type = map
}
variable "basics" {
  type = object({
    enabled             = string,
    nameNonEnv          = string,
    aliases             = list(string),
    comment             = string,
    default_root_object = any,
    is_ipv6_enabled     = any,
    http_version        = any,
    price_class         = any,
    web_acl_id          = any,
    retain_on_delete    = any,
    wait_for_deployment = any
  })
  description = "Lookup the basic arguments of the aws_cloudfront_distribution resource"
}


### Config blocks: Required maximum 1

variable "restrictions" {
  type = object({
    geo_restriction = object({
      restriction_type = string,
      locations        = any
    }),
  })
  description = "Lookup the restrictions argument of the aws_cloudfront_distribution resource"
}

variable "viewer_certificate" {
  type = object({
    acm_certificate_arn            = any,
    cloudfront_default_certificate = any,
    iam_certificate_id             = any,
    minimum_protocol_version       = any,
    ssl_support_method             = any,
  })
  description = "Lookup the viewer_certificate argument of the aws_cloudfront_distribution resource"
}


### Config blocks: Required with maximum unlimited

variable "origin" {
  type = map(object({
    domain_name           = string
    origin_id             = string
    origin_path           = any
    custom_header-defs = map(object({
      name = string,
      value = string
    })),
    s3_origin_config-defs = map(object({
      origin_access_identity = string,
    })),
    custom_origin_config-defs = map(object({
      http_port                = string
      https_port               = string
      origin_protocol_policy   = list(string)
      origin_ssl_protocols     = string
      origin_keepalive_timeout = any
      origin_read_timeout      = any
    })),
  }))
  description = "Lookup the origin argument of the aws_cloudfront_distribution resource"
}

variable "default_cache_behavior" {
  type = map(object({
    allowed_methods       = list(string)
    cached_methods        = list(string)
    forwarded_values-defs = map(object({
      cookies-defs = map(object({
        forward           = string,
        whitelisted_names = any
      })),
      query_string            = any,
      headers                 = any,
      query_string_cache_keys = any
    })),
    lambda_function_association-defs = map(object({
      event_type   = string,
      lambda_arn   = string
      include_body = any
    })),
    target_origin_id            = string,
    viewer_protocol_policy      = string,
    compress                    = any,
    default_ttl                 = any,
    field_level_encryption_id   = any,
    max_ttl                     = any,
    min_ttl                     = any,
    smooth_streaming            = any,
    trusted_signers             = any
  }))
  description = "Lookup the default_cache_behavior argument of the aws_cloudfront_distribution resource"
}




### Config blocks: Optional with maximum 1

variable "logging_config" {
  type = map(object({
    bucket          = string,
    include_cookies = any,
    prefix          = any,
  }))
  description = "Lookup the logging_config argument of the aws_cloudfront_distribution resource"
}


### Config blocks: Optional with unlimited

variable "ordered_cache_behavior" {
  type = map(object({
    allowed_methods       = list(string)
    path_pattern          = string
    cached_methods        = list(string)
    forwarded_values-defs = map(object({
      cookies-defs = map(object({
        forward           = string,
        whitelisted_names = any
      })),
      query_string            = string,
      headers                 = any,
      query_string_cache_keys = any
    })),
    target_origin_id                 = string,
    viewer_protocol_policy           = string,
    compress                         = any,
    default_ttl                      = any,
    field_level_encryption_id        = any,
    lambda_function_association-defs = map(object({
      event_type   = string,
      lambda_arn   = string
      include_body = any
    })),
    max_ttl          = any,
    min_ttl          = any,
    smooth_streaming = any,
    trusted_signers  = any
  }))
  description = "Lookup the default_cache_behavior argument of the aws_cloudfront_distribution resource"
}

variable "custom_error_response" {
  type = map(object({
    error_code            = string,
    error_caching_min_ttl = string,
    response_code         = string,
    response_page_path    = string,
  }))
  description = "Lookup the custom_error_response argument of the aws_cloudfront_distribution resource"
}