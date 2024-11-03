variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "allowed_cidrs" {
  default = "101.0.62.150/32"
}
variable "public_nacl_rules" {
  type=list(object({
    rule_number=number
    action=string
    from_port=number
    to_port=number
    protocol=string
    cidr_block=string
    egress=bool
  }))
  default = [ 
  {
  rule_number = 50
  action="allow"
  from_port = 1024
  to_port = 3388
  protocol = "6"
  cidr_block =  "0.0.0.0/0" 
  egress = false
  },
  {
  rule_number = 100
  action="allow"
  from_port = 1024
  to_port = 3388
  protocol = "17"
  cidr_block =  "0.0.0.0/0" 
  egress = false
  },
  {
  rule_number = 150
  action="allow"
  from_port = 3390
  to_port = 65535
  protocol = "6"
  cidr_block =  "0.0.0.0/0" 
  egress = false
  },
  {
  rule_number = 200
  action="allow"
  from_port = 3390
  to_port = 65535
  protocol = "17"
  cidr_block =  "0.0.0.0/0" 
  egress = false
  },
  {
    rule_number = 250
    action = "allow"
    from_port = 80
    to_port = 80
    cidr_block =  "0.0.0.0/0" 
    protocol = "6"
    egress = false
  },
  {
    rule_number = 300
    action = "allow"
    from_port = 80
    to_port = 80
    cidr_block =  "0.0.0.0/0" 
    protocol = "17"
    egress = false
  },
  {
    rule_number = 350
    action = "allow"
    from_port = 443
    to_port = 443
    cidr_block =  "0.0.0.0/0" 
    protocol = "6"
    egress = false
  },
  {
    rule_number = 400
    action = "allow"
    from_port = 443
    to_port = 443
    cidr_block =  "0.0.0.0/0" 
    protocol = "17"
    egress = false
  },
  {
    rule_number = 450
    action = "allow"
    from_port = 587
    to_port = 587
    cidr_block =  "0.0.0.0/0" 
    protocol = "tcp"
    egress = false
  },{
    rule_number = 500
    action = "allow"
    from_port = 22
    to_port = 22
    cidr_block =  "101.0.62.150/32" 
    protocol = "tcp"
    egress = false
  },
  {
    rule_number = 550
    action = "allow"
    from_port = 3389
    to_port = 3389
    cidr_block =  "101.0.62.150/32"  
    protocol = "tcp"
    egress = false
  },{
    rule_number = 600
    action = "allow"
    from_port = 22
    to_port = 22
    cidr_block =  "10.0.0.0/16"
    protocol = "tcp"
    egress = false
  },{
    rule_number = 650
    action = "allow"
    from_port = 3389
    to_port = 3389
    cidr_block =  "10.0.0.0/16"
    protocol = "tcp"
    egress = false
  },
  {
    rule_number = 50
    action = "allow"
    from_port = 1024
    to_port = 65535
    cidr_block = "0.0.0.0/0"
    protocol = "6"
    egress = true
  },{
    rule_number = 100
    action = "allow"
    from_port = 1024
    to_port = 65535
    cidr_block = "0.0.0.0/0"
    protocol = "17"
    egress = true
  },{
    rule_number = 150
    action = "allow"
    from_port = 80
    to_port = 80
    cidr_block = "0.0.0.0/0"
    protocol = "tcp"
    egress = true
  },{
    rule_number = 200
    action = "allow"
    from_port = 443
    to_port = 443
    cidr_block = "0.0.0.0/0"
    protocol = "tcp"
    egress = true
  },{
    rule_number = 250
    action = "allow"
    from_port = 22
    to_port = 22
    cidr_block =  "101.0.62.150/32" 
    protocol = "tcp"
    egress = true
  },{
    rule_number = 300
    action = "allow"
    from_port = 3389
    to_port = 3389
    cidr_block =  "101.0.62.150/32" 
    protocol = "tcp"
    egress = true
  },{
    rule_number = 350
    action = "allow"
    from_port = 22
    to_port = 22
    cidr_block =  "10.0.0.0/16" 
    protocol = "tcp"
    egress = true
  },{
    rule_number = 400
    action = "allow"
    from_port = 3389
    to_port = 3389
    cidr_block =  "10.0.0.0/16" 
    protocol = "tcp"
    egress = true
  },{
    rule_number = 450
    action = "allow"
    from_port = 587
    to_port = 587
    cidr_block =  "0.0.0.0/0" 
    protocol = "tcp"
    egress = true
  } ]
}

variable "private_nacl_rules" {
  type = list(object({
    rule_number = number
    action      = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    egress      = bool
  }))
  default = [
    # Ingress Rule: Allow all inbound traffic from within the VPC
    {
      rule_number = 100
      from_port   = 80
      to_port     = 80
      protocol    = "6"      # "-1" means all protocols
      action      = "allow"
      cidr_block  = "0.0.0.0/0" 
      egress      = false
    },
    # Ingress Rule: Allow return traffic from the internet (Ephemeral Ports)
    {
      rule_number = 150
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "0.0.0.0/0" 
      egress      = false
    },
    {
      rule_number = 200
      from_port   = 1024
      to_port     = 3388
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "0.0.0.0/0" 
      egress      = false
    },
    {
      rule_number = 250
      from_port   = 3390
      to_port     = 65535
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "0.0.0.0/0" 
      egress      = false
    },
    {
      rule_number = 300
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "10.0.0.0/16" 
      egress      = false
    },
    {
      rule_number = 350
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      action      = "allow"
      cidr_block  = "10.0.0.0/16" 
      egress      = false
    },
    {
      rule_number = 400
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "101.0.62.150/32" 
      egress      = false
    },
    {
      rule_number = 450
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "101.0.62.150/32" 
      egress      = false
    },
    {
      rule_number = 500
      from_port   = 1024
      to_port     = 3388
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "0.0.0.0/0" 
      egress      = false
    },
    {
      rule_number = 550
      from_port   = 3390
      to_port     = 65535
      protocol    = "tcp"
      action      = "allow"
      cidr_block  = "0.0.0.0/0" 
      egress      = false
    },
    # Egress Rule: Allow all outbound traffic to the internet
    {
      rule_number = 100
      from_port   = 80
      to_port     = 80
      protocol    = "6"
      action      = "allow"
      cidr_block  = "0.0.0.0/0"
      egress      = true
    },
    {
      rule_number = 150
      from_port   = 443
      to_port     = 443
      protocol    = "6"
      action      = "allow"
      cidr_block  = "0.0.0.0/0"
      egress      = true
    },
    {
      rule_number = 200
      from_port   = 0
      to_port     = 65535
      protocol    = "6"
      action      = "allow"
      cidr_block  = "10.0.0.0/16"
      egress      = true
    },
    {
      rule_number = 250
      from_port   = 0
      to_port     = 65535
      protocol    = "17"
      action      = "allow"
      cidr_block  = "10.0.0.0/16"
      egress      = true
    },
    {
      rule_number = 300
      from_port   = 22
      to_port     = 22
      protocol    = "6"
      action      = "allow"
      cidr_block  = "101.0.62.150/32"
      egress      = true
    },
    {
      rule_number = 350
      from_port   = 3389
      to_port     = 3389
      protocol    = "6"
      action      = "allow"
      cidr_block  = "101.0.62.150/32"
      egress      = true
    }
  ]
}
variable "acm_certificate_arn" {
  default = "arn:aws:acm:us-east-1:848417356303:certificate/38127a4d-3fcd-48ec-bfa9-ec9719768b5a"
}
variable "route53_zone_id" {
  default = "Z03808151DVGVDRVJFOD8"
}
# variable "repository_name" {
#   default = "shorturl"
# }
# variable "image_tag_mutability" {
#   default = "IMMUTABLE"
# }
# variable "scan_on_push" {
#   default = true
# }
variable "ecr_repo_details"{
  type=map(object({
    repository_name=string,
    image_tag_mutability=string,
    scan_on_push=bool
  }))
   default = {
     "shorturl" = {
       repository_name="shorturl"
       image_tag_mutability="IMMUTABLE"
       scan_on_push=true
     },
     "nginx"={
      repository_name="nginx"
       image_tag_mutability="IMMUTABLE"
       scan_on_push=false
     }
     "certgen"={
      repository_name="kube-webhook-certgen"
      image_tag_mutability="IMMUTABLE"
       scan_on_push=false
     }
   }
}
variable "username" {
  default = "backend"
}
variable "db_password" {
  default = "backends"
}
variable "instance_class" {
  default = "db.m5d.large"
}
variable "engine_version"{
  default = "14.12"
}
variable "engine" {
  default = "postgres"
}
variable "identifier"{
  default = "shorturl-db-instance"
}
variable "db_name" {
  default = "deeplinkurl"
}
variable "allocated_storage" {
  default = 20
}
variable "storage_type" {
  default = "gp3"
}
variable "multi_az" {
  default = false
}
variable "publicly_accessible" {
  default = false
}
variable "skip_final_snapshot" {
  default = true
}
variable "db_subnet_group"{
  default = "db-subnet-group"
}
variable "db_sg" {
  default = "db-sg"
}
variable "host_headers" {
  default = ["api.deeplink.in","kibana.deeplink.in","grafana.deeplink.in","prometheus.deeplink.in"]
}
# variable "private_nacl_rules" {
#   type = list(object({
#     rule_number =  number
#     action=string
#     from_port=string
#     to_port=string
#     protocol=string
#     cidr_block=string
#     egress=bool
#   }))
#   default = [ {
#     rule_number = 100
#     from_port = 0
#     to_port = 65535
#     cidr_block =  "10.0.0.0/16" 
#     protocol = "tcp"
#     action = "allow"
#     egress = false
#   } ,
#   {
#     rule_number = 100
#     from_port = 0
#     to_port = 65535
#     protocol = "tcp"
#     action = "allow"
#     cidr_block =  "10.0.0.0/16" 
#     egress = true
#   }]
# }
variable "cluster_name" {
  default = "acme_corp"
}
variable "node_group_name" {
  default = "acme_corp"
}
# variable "supported_azs" {
#   default = local.supported_azs
# }

