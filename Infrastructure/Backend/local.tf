locals {
  excluded_az  = "us-east-1e"
  max_azs       = 3

  # Generate a list of supported AZs, excluding the ones in `excluded_azs`
  supported_azs = [for az in data.aws_availability_zones.available.names : az if az!=local.excluded_az]
}
# Parse JSON structure of the secret string
locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_secret_value.secret_string)
}
