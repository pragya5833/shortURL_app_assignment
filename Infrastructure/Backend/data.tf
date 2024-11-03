data "aws_availability_zones" "available" {
  state = "available"
}
variable "excluded_azs" {
  description = "AZs to exclude"
  type        = list(string)
  default     = ["us-east-1e"]  # Add any AZs you want to exclude
}
# Retrieve secret metadata
data "aws_secretsmanager_secret" "db_secret" {
  name = "prod/db/postgres" # Replace with your secret name in AWS Secrets Manager
}

# Retrieve the latest version of the secret's value
data "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}
# data "terraform_remote_state" "bastion" {
#   backend = "s3"
#   config = {
#     bucket = "assignmentacmecorp"
#     key    = "bastion-ec2.tfstate"
#     region = "us-east-1"
#   }
# }

