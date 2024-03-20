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
              # Install Jenkins
              sudo apt-get update
              sudo apt-get install -y default-jdk
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update
              sudo apt-get install -y jenkins
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
