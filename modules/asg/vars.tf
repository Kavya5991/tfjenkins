variable "asg_security_group_name" {
  type    = string
  default = "jenkins-asg-security-group"
}

variable "alb_security_group_id" {
  type    = list(string)
}

variable "launch_template_name" {
  type    = string
  default = "jenkins-launch-template"
}

variable "launch_template_ec2_name" {
  type    = string
  default = "jenkins-asg-ec2"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  type        = string
  description = "The AMI ID for instances in ASG"
  default     = "ami-0d7a109bf30624c99"
}
variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "The desired number of EC2 Instances in the ASG"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with sg "
  type        = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The list of public subnet IDs to launch the EC2 instances in ASG"
}

variable "target_group_arn" {
  type        = list(string)
  description = "The ARN OF LB targetgroup"
}