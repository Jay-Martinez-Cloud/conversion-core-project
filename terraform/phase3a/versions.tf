terraform {
  required_version = ">= 1.6.0" //tf version greater than/equal to 1.6.0 
  //prevents old versions that could cause syntax issues
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0" //~ means to use this range 5.0-5.99 but 6.0 or higher
    }                   //these constraints protect infastructure from unexpected breakage
  }
}

/*
“>= 1.6.0 ensures we’re using a modern Terraform binary, and 
~> 5.0 allows safe provider updates while preventing breaking major-version upgrades.”
*/
