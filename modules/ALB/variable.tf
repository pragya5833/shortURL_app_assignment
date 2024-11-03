variable "vpc_id" {
  
}
variable "public_subnet_ids" {
  
}
variable "acm_certificate_arn" {
  
}
variable "route53_zone_id" {
  
}
# variable "node_ids" {
  
# }
# ALB Module: Define node_groups Variable
# variable "node_group" {
#   description = "Node group information from the EKS module"
#   type = object({
#     node_group_name = string
#     resources       = list(object({
#       autoscaling_groups  = list(object({ name = string }))
#       security_group_ids  = list(string)
#     }))
#   })
# }


variable "cluster_name" {
  
}
variable "node_group_name" {
  
}
variable "host_headers" {
  
}