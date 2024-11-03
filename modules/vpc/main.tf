resource "aws_vpc" "main_vpc" {
    cidr_block = var.cidr_range
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = local.common_tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = local.common_tags
}

resource "aws_subnet" "public_subnets" {
    vpc_id = aws_vpc.main_vpc.id
  count = length(var.supported_azs)
  map_public_ip_on_launch = true
  cidr_block = cidrsubnet(aws_vpc.main_vpc.cidr_block,8,count.index+1)
  availability_zone = var.supported_azs[count.index]
  tags = local.common_tags
}

resource "aws_subnet" "private_subnets" {
  count = length(var.supported_azs)
  vpc_id = aws_vpc.main_vpc.id
  availability_zone = var.supported_azs[count.index]
  cidr_block = cidrsubnet(aws_vpc.main_vpc.cidr_block,8,count.index+length(var.supported_azs)+1)
  tags = local.common_tags
}

resource "aws_eip" "elstic_ip_nat" {
  count = length(var.supported_azs)
  vpc = true
  tags = local.common_tags
}

resource "aws_nat_gateway" "public_nat_gateway" {
  count = length(var.supported_azs)
  subnet_id = element(aws_subnet.public_subnets.*.id,count.index)
  allocation_id = element(aws_eip.elstic_ip_nat.*.id,count.index)
  tags = local.common_tags
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = local.common_tags
}

resource "aws_route_table" "private_route_table" {
    count=length(var.supported_azs)
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.public_nat_gateway.*.id,count.index)
  }
  tags = local.common_tags
}
resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.supported_azs)
  subnet_id = element(aws_subnet.public_subnets.*.id,count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.supported_azs)
  subnet_id = element(aws_subnet.private_subnets.*.id,count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id,count.index)
}

resource "aws_network_acl" "public_nacl" {
    vpc_id = aws_vpc.main_vpc.id
  dynamic "ingress" {
    for_each = [for rule in var.public_nacl_rules: rule if !rule.egress]
    content {
      rule_no = ingress.value.rule_number
      action = ingress.value.action
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_block = ingress.value.cidr_block
    }
  }
  dynamic "egress" {
    for_each = [for rule in var.public_nacl_rules: rule if rule.egress]
    content {
      rule_no = egress.value.rule_number
      action = egress.value.action
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_block = egress.value.cidr_block
    }
  }
  tags = local.common_tags
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main_vpc.id
  dynamic "ingress" {
    for_each = [for rule in var.private_nacl_rules: rule if !rule.egress]
    content {
      rule_no = ingress.value.rule_number
      action = ingress.value.action
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_block = ingress.value.cidr_block
    }
  }
  dynamic "egress" {
    for_each = [for rule in var.private_nacl_rules: rule if rule.egress]
    content {
      rule_no = egress.value.rule_number
      action = egress.value.action
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_block = egress.value.cidr_block
    }
  }
  tags = local.common_tags
}
resource "aws_network_acl_association" "public_nacl_association" {
  for_each = { for idx, id in local.public_subnet_ids : idx => id }

  subnet_id      = each.value
  network_acl_id = aws_network_acl.public_nacl.id
}

resource "aws_network_acl_association" "private_nacl_association" {
   for_each = { for idx, id in local.private_subnet_ids : idx => id }

  subnet_id      = each.value
  network_acl_id = aws_network_acl.private_nacl.id
}