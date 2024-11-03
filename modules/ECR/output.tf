# output "ecr_repository_url" {
#   value = aws_ecr_repository.shorturl.repository_url
# }
output "ecr_repository_url" {
  value = {for repo_name,repo in aws_ecr_repository.repos: repo_name=>repo.repository_url}
}