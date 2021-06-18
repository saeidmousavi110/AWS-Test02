terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/Users/saeid_000/.aws/credentials"
}



variable "subnet_prefix" {
   type        = string
   default     = ""
  description = "cider block for the subnet"
}


# Create a VPC
resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test-vpc"
  }
}


# Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-gw"
  }
}


# Create a route table
resource "aws_route_table" "test-route-table-01" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "test-route-table"
  }
}


# Create a subnet
resource "aws_subnet" "test-subnet-1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.subnet_prefix[0].cider_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

# Create another subnet
resource "aws_subnet" "test-subnet-2" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.subnet_prefix[1].cider_block
  availability_zone = "us-east-1b"

  tags = {
    Name = var.subnet_prefix[1].name 
  }
}  


# Associate the route table to the subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.test-subnet-1.id
  route_table_id = aws_route_table.test-route-table-01.id
}
resource "aws_route_table_association" "b" {
  #  gateway_id     = aws_internet_gateway.gw.id
  subnet_id      = aws_subnet.test-subnet-2.id
  route_table_id = aws_route_table.test-route-table-01.id
}


# Create a Security Group to allow ports 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.test-vpc.id

  ingress {
    description      = "HTTPs from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from VPC"
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
    Name = "allow_web"
  }
}


# Create a network interface
resource "aws_network_interface" "test-webserver-nic" {
  subnet_id       = aws_subnet.test-subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
}

# Create an Elastic IP and assign to the network interface
resource "aws_eip" "test-EIP-one" {
  vpc                       = true
  network_interface         = aws_network_interface.test-webserver-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}


# Create an Ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  vpc_id     = aws_vpc.test-vpc.id
  subnet_id       = aws_subnet.test-subnet-1.id
  availability_zone = "us-east-1a"
  key_name          = "EC2 Tutorial"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.test-webserver-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first terraform creation > /var/www/html/index.html'
              EOF

  tags = {
    Name = "web-server"
  }
}



