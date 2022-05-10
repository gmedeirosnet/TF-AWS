## TERRAFORM CONFIGURATION
##
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11.0"
    }
  }
  required_version = ">= 0.14.9"
}

## CONFIGURE THE AWS PROVIDER
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  profile = "tfaws"
  region  = "us-east-1"
}


##############
## NETWORK (VPC | SUBNET | SECURITY GROUP)
## https://www.jlcp.com.br/criando-rede-vpc-na-aws-com-terraform
##############


## EC2 VPC
resource "aws_vpc" "web_vpc" {
  ## Tenancy defines how EC2 instances are distributed across physical hardware and affects pricing.
  instance_tenancy     = "default"
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "main"
  }
}

## SUBNET { Private }
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    name = "Private subnet"
  }
}

## SUBNET { Public }
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    name = "Public subnet"
  }
}

## GATEWAY INTERNET
resource "aws_internet_gateway" "IGW_web" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    Name = "Internet gateway teste"
  }
}

## ROUTE TABLE
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    Name = "Private Route table"
  }
}

## ROUTING
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW_web.id
}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

#######################
## SECURITY
#######################
## sECURITY GROUP
resource "aws_security_group" "web-sg" {
  name        = "Allow all"
  description = "Allow all conections from internet to VPC"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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
    name = "Allow all"
  }

}

## NETWORK ACL
resource "aws_network_acl" "public_NACL" {
  vpc_id     = aws_vpc.web_vpc.id
  subnet_ids = [aws_subnet.private_subnet.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }


  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Public NACL"
  }
}
####################
## EC2 INSTANCE
####################

## NETWORK INTERFACE
resource "aws_network_interface" "web" {
  subnet_id       = aws_subnet.private_subnet.id
  private_ips     = ["172.16.0.10/24"]
  security_groups = [aws_security_group.web-sg.id]

  attachment {
    instance     = aws_instance.web.id
    device_index = 1
  }
}

## INSTANCE BASED ON AMI BY MARKTPLACE
## UBUNTU 22.04 LTS x64
resource "aws_instance" "web" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"

  # network_interface {
  #   network_interface_id = aws_network_interface.web.id
  #   device_index         = 0
  # }

  tags = {
    name = "web"
  }
}
