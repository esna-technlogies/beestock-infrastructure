provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_credentials_profile}"
}

terraform {
  backend "s3" {
    bucket = "beestock-terraform-states"
    key = "dev/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}

/* ECS Cluster */
resource "aws_ecs_cluster" "dev_beestock" {
  name = "${var.ecs_cluster_name}"
}


data "aws_availability_zones" "all" {}