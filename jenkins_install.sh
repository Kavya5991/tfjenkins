#!/bin/bash
sudo su
yum update -y  # updates the package list and upgrades installed packages on the system
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  #downloads the Jenkins repository configuration file and saves it to /etc/yum.repos.d/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key  #imports the GPG key for the Jenkins repository. This key is used to verify the authenticity of the Jenkins packages
yum upgrade -y #  upgrades packages again, which might be necessary to ensure that any new dependencies required by Jenkins are installed
dnf install java-11-amazon-corretto -y  # installs Amazon Corretto 11, which is a required dependency for Jenkins.
yum install jenkins -y  #installs Jenkins itself
systemctl enable jenkins  #enables the Jenkins service to start automatically at boot time
systemctl start jenkins   #starts the Jenkins service immediately a head