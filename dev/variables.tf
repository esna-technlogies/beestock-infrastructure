/* AWS */
variable "aws_account_id" {}

variable "aws_region" {
  default = "us-west-2"
}

//variable "availability_zone_a" {
//  default = "us-east-2a"
//}
//variable "availability_zone_b" {
//  default = "us-east-2b"
//}

variable "aws_credentials_profile" {
  default = "devops"
}

variable "s3_bucket_of_terraform_states" {
  default = "beestock-terraform"
}

variable "s3_bucket_key_of_terraform_state_of_development" {
  default = "dev/terraform.tfstate"
}

/* ECS */
variable "ecs_cluster_name" {
  default = "dev-beestock"
}

variable "webapp_container_name" {
  default = "dev-webapp"
}

variable "webapp_container_image_name" {
  default = "dev-beestock-webapp"
}

variable "admin_dashboard_container_name" {
  default = "dev-admin-dashboard"
}

variable "admin_dashboard_container_image_name" {
  default = "dev-beestock-admin-dashboard"
}
