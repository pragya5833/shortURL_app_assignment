provider "aws" {
  region = "us-east-1"
#   profile = 
}
provider "tls"{

}
terraform {
    required_version = ">=1.8.0"
  backend "s3" {
    region = "us-east-1"
    bucket = "assignmentacmecorp"
    key = "assignmentacmecorp.tfstate"
  }
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 5.70.0"
    }
     kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
  }
}