resource "aws_security_group" "asg_security_group" {
  name        = var.asg_security_group_name
  description = "ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = var.alb_security_group_id
    #[aws_security_group.alb_security_group.id]
  }
   ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.asg_security_group_name
  }
}

resource "aws_key_pair" "tf-key" {
  key_name   = "tfjenkinskey"
   public_key = tls_private_key.rsa.public_key_openssh
}
//generate ssh keys using rsa algorithm
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
//store private key in local system
resource "local_file" "tf-key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "tfjenkinskey"
}

resource "aws_launch_template" "launch_template" {
  name          = var.launch_template_name
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = "tfjenkinskey"
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.asg_security_group.id]
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
    Name = var.launch_template_ec2_name
    }
  }

 user_data =  <<-EOF
              #!/bin/bash
sudo su
yum update -y  # updates the package list and upgrades installed packages on the system
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  #downloads the Jenkins repository configuration file and saves it to /etc/yum.repos.d/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key  #imports the GPG key for the Jenkins repository. This key is used to verify the authenticity of the Jenkins packages
yum upgrade -y #  upgrades packages again, which might be necessary to ensure that any new dependencies required by Jenkins are installed
dnf install java-11-amazon-corretto -y  # installs Amazon Corretto 11, which is a required dependency for Jenkins.
yum install jenkins -y  
systemctl enable jenkins  #enables the Jenkins service to start automatically at boot time
systemctl start jenkins                
EOF
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.public_subnet_ids
  #[for i in aws_subnet.public_subnet[*] : i.id]
  target_group_arns   = var.target_group_arn
  #[aws_lb_target_group.target_group.arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name = "jenkins_scale_out"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.auto_scaling_group.name}"
}
resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name = "jenkins_cpu_alarm_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "70"
dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.auto_scaling_group.name}"
  }
alarm_description = "This metric monitor EC2 instance CPU utilization to scale out instances when cpu utilisaton reaches 70%"
  alarm_actions = [ "${aws_autoscaling_policy.scale_out_policy.arn}" ]
}
resource "aws_autoscaling_policy" "scale_policy_in" {
  name = "scale_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.auto_scaling_group.name}"
}
resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name = "jenkins_cpu_alarm_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "40"
dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.auto_scaling_group.name}"
  }
alarm_description = "This metric monitor EC2 instance CPU utilization to scale in instances when cpu utilisaton reaches 30%"
  alarm_actions = [ "${aws_autoscaling_policy.scale_policy_in.arn}" ]
}
