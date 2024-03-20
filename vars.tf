/* variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
  default     = "172.16.0.0/16"  
} 

 variable "public_subnets_cidr" {
  description = "CIDR range for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "CIDR Range for private subnets"
  type        = list(string)
  default     = ["10.0.128.0/24", "10.0.129.0/24"]
}
 variable "availability_zones" {
  description = "The availability zones where subnets,ec2 instance will be launched"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] 
}

 variable "launch_template_name" {
  type    = string
  default = "jenkins-launch-template"
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
}  */
