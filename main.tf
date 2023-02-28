# Provider
provider "aws" {
  region = "us-east-1"
}

# AMI
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 instance
resource "aws_instance" "ec2" {
  ami                  = data.aws_ami.latest_amazon_linux.id
  subnet_id            = aws_default_subnet.default_subnet.id
  instance_type        = "t3.medium"
  iam_instance_profile = "LabInstanceProfile"
  key_name             = aws_key_pair.key_pair.key_name
  security_groups      = [aws_security_group.sg.id]
  user_data            = <<EOF
  #!/bin/bash
  set -ex
  sudo yum update -y
  sudo yum install git -y
  git config --global user.name "amandhal"
  git config --global user.email "amandhal.ad@gmail.com"
  git config --global core.editor "vim"
  sudo yum install docker -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -a -G docker ec2-user
  curl -sLo kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
  sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
  rm -f ./kind
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f ./kubectl
EOF
  tags = {
    Name = "ec2_assignment2"
  }
}

# Default subnet
resource "aws_default_subnet" "default_subnet" {
  availability_zone = "us-east-1a"
}

# SSH key pair 
resource "aws_key_pair" "key_pair" {
  key_name   = "id_rsa"
  public_key = file("/home/ec2-user/.ssh/id_rsa.pub")
}

# Security Group
resource "aws_security_group" "sg" {
  ingress {
    description      = "30000 from everywhere"
    from_port        = 30000
    to_port          = 30000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "30001 from everywhere"
    from_port        = 30001
    to_port          = 30001
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_assignment2"
  }
}

# ECR Repos
resource "aws_ecr_repository" "ecr_repos" {
  count = length(var.ecr_repo_names)
  name  = var.ecr_repo_names[count.index]
}