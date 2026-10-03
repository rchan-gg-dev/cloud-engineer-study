variable "enable_ssm_endpoints" {
  description = "Whether to create SSM VPC endpoints for private EC2"
  type        = bool
  default     = false
}