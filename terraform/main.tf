provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      Created_by  = "terraform"
      Repo        = "BPChargemaster/AmazonConnect_Callback"
      Environment = var.env_type
    }
  }
}

data "aws_caller_identity" "current" {}
