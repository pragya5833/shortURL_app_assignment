variable "primary_bucket_name_frontend" {
 default =  "frontendshorturlhost"
}
variable "failover_bucket_name_frontend" {
 default =  "frontendshorturlreplicahost"
}
variable "primary_bucket_name_landing" {
 default =  "landingpageshorturlhost"
}
variable "failover_bucket_name_landing" {
 default =  "landingpageshorturlreplicahost"
}
variable "frontend_zone_id" {
  default = "Z07096863MXF521Y9M1G8"
}
variable "landing_zone_id" {
  default = "Z04985902T9PL2ABUK902"
}