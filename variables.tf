variable "name" {
  description = "Name of the API Gateway v2 API"
  type        = string
}

variable "protocol_type" {
  description = "Protocol type for the API Gateway v2 API. Valid values are HTTP and WEBSOCKET"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "WEBSOCKET"], var.protocol_type)
    error_message = "Protocol type must be either HTTP or WEBSOCKET."
  }
}

variable "description" {
  description = "Description of the API Gateway v2 API"
  type        = string
  default     = null
}

variable "routes" {
  description = "Map of route configurations"
  type = map(object({
    route_key          = string
    authorization_type = optional(string, "NONE")
    authorizer_id      = optional(string)
    target             = optional(string)
    operation_name     = optional(string)
    api_key_required   = optional(bool, false)
  }))
  default = {}
}

variable "integrations" {
  description = "Map of integration configurations"
  type = map(object({
    integration_type       = string
    integration_method     = string
    integration_uri        = optional(string)
    lambda_arn             = optional(string)
    lambda_function_arn    = optional(string)
    payload_format_version = optional(string, "2.0")
    timeout_milliseconds   = optional(number, 29000)
    passthrough_behavior   = optional(string, "WHEN_NO_MATCH")
    connection_type        = optional(string)
    connection_id          = optional(string)
    request_parameters     = optional(map(string))
    response_parameters = optional(list(object({
      status_code = string
      mappings    = map(string)
    })))
  }))
  default = {}
}

variable "stage_name" {
  description = "Name of the stage to create"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Whether to automatically deploy the stage"
  type        = bool
  default     = true
}

variable "enable_domain_name" {
  description = "Whether to create a custom domain name"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom domain name for the API"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain"
  type        = string
  default     = null
}

variable "domain_mapping_key" {
  description = "Mapping key for the domain name"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Whether to enable CloudWatch logging for the API"
  type        = bool
  default     = false
}

variable "log_group_retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "skip_destroy" {
  description = "Whether to skip destroy for CloudWatch log group (useful for testing)"
  type        = bool
  default     = false
}

variable "cors_configuration" {
  description = "CORS configuration for HTTP APIs"
  type = object({
    allow_credentials = optional(bool, false)
    allow_headers     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["*"])
    allow_origins     = optional(list(string), ["*"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 300)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the API Gateway v2 API"
  type        = map(string)
  default     = {}
}
