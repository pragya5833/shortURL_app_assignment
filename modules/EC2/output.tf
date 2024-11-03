output "public_ip" {
  value = aws_instance.bastion_host.public_ip
}
output "bastion_sg" {
  value = aws_security_group.bastion_security_group.id
}
output "bastion_role" {
  value = aws_iam_role.bastion_trust_relationship.arn
}
