data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    project = var.project_name
    env     = var.env
    managed = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = "conversion-${var.env}"
  cidr = "10.50.0.0/16"
  tags = local.common_tags
}

module "runner" {
  source = "../../modules/runner_ec2"

  name      = "conversion-${var.env}"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  sql_sa_password = var.sql_sa_password
  tags            = local.common_tags
}

module "artifacts_s3" {
  source = "../../modules/artifacts_s3"

  bucket_name        = "${var.project_name}-${var.env}-${data.aws_caller_identity.current.account_id}-artifacts"
  force_destroy      = true
  versioning_enabled = false

  lifecycle_days   = 30
  lifecycle_prefix = "runs/${var.env}/"

  tags = local.common_tags
}

output "artifacts_bucket" {
  value = module.artifacts_s3.bucket_name
}


