variable "pub_key" {
    type = string
    default = "/home/vagrant/.ssh/id_rsa.pub"
}

variable "domain_name" {
  default    = "osinachi.engineer"
  type        = string
  description = "Domain name"
}