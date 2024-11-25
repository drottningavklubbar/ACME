terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region              = "eu-central-1"
  profile             = "253490793778"
  allowed_account_ids = ["253490793778"]
}
