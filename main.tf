terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
}

variable "subnet_prefix" {
  description = "cidr_block of the subnet"
}


# Create a VPC
resource "aws_vpc" "web-tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gw-terraform" {
  vpc_id = aws_vpc.web-tf-vpc.id

  tags = {
    Name = "gw-project-terraform"
  }
}

# Create a Route table
resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.web-tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-terraform.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw-terraform.id
  }

  tags = {
    Name = "Dev"
  }
}

# Create a subnet
resource "aws_subnet" "subnet-project-tf" {
  vpc_id     = aws_vpc.web-tf-vpc.id
  cidr_block = var.subnet_prefix[0].cidr_block
  availability_zone = "eu-west-3a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "route-table-project-tf" {
  subnet_id      = aws_subnet.subnet-project-tf.id
  route_table_id = aws_route_table.dev-route-table.id
}

# Create a security group
resource "aws_security_group" "web_server_sg_tf" {
    name        = "web-server-sg-tf"
    description = "Allow HTTPS/HTTP/SSH to web server"
    vpc_id      = aws_vpc.web-tf-vpc.id

    ingress {
        description = "HTTPS ingress"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP ingress"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH ingress"
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
        Name = "allow_web_tf"
    }
}

# Create a Network interface
resource "aws_network_interface" "web-server-nic" {
    subnet_id       = aws_subnet.subnet-project-tf.id
    private_ips     = ["10.0.1.50"]
    security_groups = [aws_security_group.web_server_sg_tf.id]
}

# Create an Elastic IP
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.gw-terraform ]
}

output "serveur_public_ip" {
  value = aws_eip.one.public_ip
}

# Create a ubuntu server
resource "aws_instance" "my-instance-terraform" {
  ami = "ami-00ac45f3035ff009e"
  instance_type = "t2.micro"
  availability_zone = "eu-west-3a"
  key_name = "web-server-tf"
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = "${file("script.sh")}"


  tags = {
    Name = "ubuntu-tf-web-server"
  }
  
}

output "serveur_private_ip" {
  value = aws_instance.my-instance-terraform.private_ip
}

output "serveur_id" {
  value = aws_instance.my-instance-terraform.id
}