provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_credentials_profile}"
}

/*--------------------------------------------*/
/*-- Terraform State Backend Configurations --*/
/*--------------------------------------------*/

terraform {
  backend "s3" {
    bucket = "beestock-terraform"
    key = "dev/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }
}
