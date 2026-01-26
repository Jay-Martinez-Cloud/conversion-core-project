variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "sql_sa_password" {
  type      = string
  sensitive = true
}

variable "project_name" {
  type        = string
  description = "Project name prefix used for naming/tagging resources."
  default     = "conversion-core"
}
