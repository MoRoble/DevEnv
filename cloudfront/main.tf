resource "aws_cloudfront_distribution" "objs" {

  ### Basic resource arguments

  enabled = var.basics["enabled"]
  aliases = var.basics["aliases"]
  comment = var.basics["comment"]

  default_root_object = var.basics["default_root_object"]
  is_ipv6_enabled     = var.basics["is_ipv6_enabled"]
  http_version        = var.basics["http_version"]
  price_class         = var.basics["price_class"]
  web_acl_id          = var.basics["web_acl_id"]
  retain_on_delete    = var.basics["retain_on_delete"]
  wait_for_deployment = var.basics["wait_for_deployment"]



  ### Config blocks: Required with maximum 1

  restrictions {
    geo_restriction {
      restriction_type = var.restrictions.geo_restriction["restriction_type"]
      locations = var.restrictions.geo_restriction["locations"]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate["acm_certificate_arn"]
    cloudfront_default_certificate = var.viewer_certificate["cloudfront_default_certificate"]
    iam_certificate_id             = var.viewer_certificate["iam_certificate_id"]
    minimum_protocol_version       = var.viewer_certificate["minimum_protocol_version"]
    ssl_support_method             = var.viewer_certificate["ssl_support_method"]
  }


  ### Config blocks: Required with maximum unlimited

  dynamic "origin" {
    for_each = var.origin
    content {
      domain_name = origin.value["domain_name"]
      origin_id   = origin.value["origin_id"]

      origin_path   = origin.value["origin_path"]
      dynamic "custom_header" {
        for_each = origin.value["custom_header-defs"]
        content {
          name  = custom_header.value["name"]
          value = custom_header.value["value"]
        }
      }
      dynamic "s3_origin_config" {
        for_each = origin.value["s3_origin_config-defs"]
        content {
          origin_access_identity = s3_origin_config.value["origin_access_identity"]
        }
      }
      dynamic "custom_origin_config" {
        for_each = origin.value["custom_origin_config-defs"]
        content {
          http_port                = custom_origin_config.value["http_port"]
          https_port               = custom_origin_config.value["https_port"]
          origin_protocol_policy   = custom_origin_config.value["origin_protocol_policy"]
          origin_ssl_protocols     = custom_origin_config.value["origin_ssl_protocols"]
          origin_keepalive_timeout = custom_origin_config.value["origin_keepalive_timeout"]
          origin_read_timeout      = custom_origin_config.value["origin_read_timeout"]
        }
      }
    }
  }

  dynamic "default_cache_behavior" {
    for_each = var.default_cache_behavior
    content {
      allowed_methods             = default_cache_behavior.value["allowed_methods"]
      cached_methods              = default_cache_behavior.value["cached_methods"]
      dynamic "forwarded_values" {
        for_each = default_cache_behavior.value["forwarded_values-defs"]
        content {
          dynamic "cookies" {
            for_each = forwarded_values.value["cookies-defs"]
            content {
              forward           = cookies.value["forward"]
              whitelisted_names = cookies.value["whitelisted_names"]
            }
          }
          query_string            = forwarded_values.value["query_string"]
          headers                 = forwarded_values.value["headers"]
          query_string_cache_keys = forwarded_values.value["query_string_cache_keys"]
        }
      }
      dynamic "lambda_function_association" {
        for_each = default_cache_behavior.value["lambda_function_association-defs"]
        content {
          event_type   = lambda_function_association.value["event_type"]
          lambda_arn   = lambda_function_association.value["lambda_arn"]
          include_body = lambda_function_association.value["include_body"]
        }
      }
      target_origin_id            = default_cache_behavior.value["target_origin_id"]
      viewer_protocol_policy      = default_cache_behavior.value["viewer_protocol_policy"]
      compress                    = default_cache_behavior.value["compress"]
      default_ttl                 = default_cache_behavior.value["default_ttl"]
      field_level_encryption_id   = default_cache_behavior.value["field_level_encryption_id"]
      max_ttl                     = default_cache_behavior.value["max_ttl"]
      min_ttl                     = default_cache_behavior.value["min_ttl"]
      smooth_streaming            = default_cache_behavior.value["smooth_streaming"]
      trusted_signers             = default_cache_behavior.value["trusted_signers"]
    }
  }




  ### Config blocks: Optional with maximum 1

  dynamic "logging_config" {
    for_each = var.logging_config
    content {
      bucket          = logging_config.value["bucket"]
      include_cookies = logging_config.value["include_cookies"]
      prefix          = logging_config.value["prefix"]
    }
  }



  ### Config blocks: Optional with maximum unlimited

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior
    content {
      allowed_methods           = ordered_cache_behavior.value["allowed_methods"]
      path_pattern              = ordered_cache_behavior.value["path_pattern"]
      cached_methods            = ordered_cache_behavior.value["cached_methods"]
      target_origin_id          = ordered_cache_behavior.value["target_origin_id"]
      viewer_protocol_policy    = ordered_cache_behavior.value["viewer_protocol_policy"]
      compress                  = ordered_cache_behavior.value["compress"]
      default_ttl               = ordered_cache_behavior.value["default_ttl"]
      field_level_encryption_id = ordered_cache_behavior.value["field_level_encryption_id"]
      max_ttl                   = ordered_cache_behavior.value["max_ttl"]
      min_ttl                   = ordered_cache_behavior.value["min_ttl"]
      smooth_streaming          = ordered_cache_behavior.value["smooth_streaming"]
      trusted_signers           = ordered_cache_behavior.value["trusted_signers"]
      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value["forwarded_values-defs"]
        content {
          dynamic "cookies" {
            for_each = forwarded_values.value["cookies-defs"]
            content {
              forward           = cookies.value["forward"]
              whitelisted_names = cookies.value["whitelisted_names"]
            }
          }
          query_string            = forwarded_values.value["query_string"]
          headers                 = forwarded_values.value["headers"]
          query_string_cache_keys = forwarded_values.value["query_string_cache_keys"]
        }
      }
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value["lambda_function_association-defs"]
        content {
          event_type   = lambda_function_association.value["event_type"]
          lambda_arn   = lambda_function_association.value["lambda_arn"]
          include_body = lambda_function_association.value["include_body"]
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_response
    content {
      error_code            = custom_error_response.value.error_code
      error_caching_min_ttl = custom_error_response.value["error_caching_min_ttl"]
      response_code         = custom_error_response.value["response_code"]
      response_page_path    = custom_error_response.value["response_page_path"]
    }
  }


  tags  = merge(
    var.commonTags,
    { Name="${var.basics["nameNonEnv"]}-${local.envName}", Role ="Cloudfront CDN" }
  )

}
