variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for tagging"
  type        = string
  default     = "epl-conversion"
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
  default     = "dev"
}


variable "mssql_sa_password" {
  description = "SA password for SQL Server container (do not commit the value)"
  type        = string
  sensitive   = true
}
