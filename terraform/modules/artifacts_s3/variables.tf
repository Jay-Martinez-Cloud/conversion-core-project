variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for conversion artifacts."
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Allow Terraform to delete bucket even if it contains objects (dev convenience)."
}

variable "versioning_enabled" {
  type        = bool
  default     = false
  description = "Enable versioning (usually off for dev, on for prod)."
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional KMS key ARN. If null, uses SSE-S3 (AES256)."
}

variable "lifecycle_days" {
  type        = number
  default     = 30
  description = "Expire objects after N days. Set null to disable lifecycle expiration."
}

variable "lifecycle_prefix" {
  type        = string
  default     = "runs/dev/"
  description = "Prefix the lifecycle rule applies to."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the bucket."
}
