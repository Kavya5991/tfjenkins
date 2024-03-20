variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "az_names" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}

variable "private_subnets_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["172.16.10.0/24", "172.16.11.0/24"]
}

variable "vpc_name" {
  type    = string
  default = "jenkins-vpc"
}

variable "internet_gateway_name" {
  type    = string
  default = "jenkins-internet-gateway"
}

variable "public_subnet_name" {
  type    = string
  default = "jenkins-public-subnet"
}

variable "private_subnet_name" {
  type    = string
  default = "jenkins-private-subnet"
}

variable "public_route_table_name" {
  type    = string
  default = "jenkins-public-route-table"
}

variable "private_route_table_name" {
  type    = string
  default = "jenkins-private-route-table"
}

variable "elastic_ip_name" {
  type    = string
  default = "jenkins-elastic-ip"
}

variable "nat_gateway_name" {
  type    = string
  default = "jenkins-nat-gateway"
}