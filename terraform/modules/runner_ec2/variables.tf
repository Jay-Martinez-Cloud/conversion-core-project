variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# SQL Server container config
variable "sql_sa_password" {
  type      = string
  sensitive = true
}

variable "sql_port" {
  type    = number
  default = 1433
}
