provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project = "conversion-core"
      env     = var.env
    }
  }
}
