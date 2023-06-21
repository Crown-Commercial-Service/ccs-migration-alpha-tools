variable "domain_name" {
  type        = string
  description = "Fully qualified domain name of the certificate to create"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of the Hosted Zone in which to create the certificate validation record(s)"
}
