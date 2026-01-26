terraform {
  backend "s3" {
    bucket         = "jaymartinez-conversion-tfstate-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "conversion-tf-lock"
    encrypt        = true
  }
}
