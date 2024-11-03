resource "aws_ecr_repository" "repos" {
    for_each = var.ecr_repo_details
  name                 = each.value.repository_name
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}


