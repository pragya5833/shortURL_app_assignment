output "public_subnet" {
  value = aws_subnet.public_subnets.*.id
}
output "private_subnet" {
  value = aws_subnet.private_subnets.*.id
}
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}