variable "vpc_cidr_block" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnets" {
  type  = list(string)
}

variable "public_subnets" {
  type  = list(string)
}

variable "zones" {
  type  = list(string)
}