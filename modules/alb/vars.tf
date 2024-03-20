variable "alb_security_group_name" {
  type    = string
  default = "jenkins-alb-security-group"
}
variable "alb_name" {
  type    = string
  default = "jenkins-external-alb"
}

variable "target_group_name" {
  type    = string
  default = "jenkins-alb-target-group"
}

variable "server_port" {
  description = "The port the web server will be listening"
  type        = number
  default     = 8080
}

variable "elb_port" {
  description = "The port the elb will be listening"
  type        = number
  default     = 80
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with sg "
  type        = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The list of public subnet IDs to launch the EC2 instances in ASG"
}

/* variable "private_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs to launch the EC2 instances in ASG"
} */