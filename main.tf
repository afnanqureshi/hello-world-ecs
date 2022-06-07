# Backend configuration for terraform state file
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "state/terraform_state.tfstate"
    region = "ca-central-1"
  }
}