terragrunt = {
  terraform {
    # Force Terraform to keep trying to acquire a lock for
    # up to 10 minutes if someone else already has the lock
    extra_arguments "retry_lock" {
      commands = [
        "init",
        "apply",
        "refresh",
        "import",
        "plan",
        "taint",
        "untaint"
      ]

      arguments = [
        "-lock-timeout=10m"
      ]
    }
  }

  # Configure Terragrunt to automatically store tfstate files in S3
  remote_state {
    backend = "s3"
    config {
      bucket          = "beestock-terraform"
      key             = "dev/terraform.tfstate"
      region          = "us-west-2"
      encrypt         = true
      dynamodb_table  = "terraform-state-development-lock"
      profile         = "devops"
    }
  }
}
