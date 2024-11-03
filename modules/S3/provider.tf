provider "aws" {
  region = "us-east-1"
}
provider "aws" {
  region = "eu-central-1"
  alias="euc"
}