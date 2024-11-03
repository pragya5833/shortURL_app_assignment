provider "aws" {
  region = "us-east-1"
#   profile = 
}

terraform {
    required_version = ">=1.8.0"
  backend "s3" {
    region = "us-east-1"
    bucket = "assignmentacmecorpfe"
    key = "assignmentacmecorp.tfstate"
  }
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 5.70.0"
    }
     
  }
}