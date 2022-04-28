## TERRAFORM CONFIGURATION
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
provider "aws" {
  profile = "tfaws"
  region  = "us-east-1"
}

## EC2 VPC
resource "aws_vpc" "web_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "Main"
  }
}

##############
## NETWORK
## https://www.jlcp.com.br/criando-rede-vpc-na-aws-com-terraform
##############

## SUBNET
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    name = "Public subnet"
  }
}

## GATEWAY INTERNET
resource "aws_internet_gateway" "IGW_teste" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    Name = "Internet gateway teste"
  }
}

## ROUTE TABLE
resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    Name = "Public Route table"
  }
}

## ROUTING
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.Public_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW_teste.id
}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public_RT.id
}

## NETWORK ACL
resource "aws_network_acl" "public_NACL" {
  vpc_id     = aws_vpc.web_vpc.id
  subnet_ids = [aws_subnet.public_subnet.id]

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
resource "aws_network_interface" "inet0" {
  subnet_id = aws_subnet.public_subnet.id
  private_ip = "172.16.0.1"

  tags ={
      name = "Primary network interface"
  }
}



## INSTANCE
resource "aws_instance" "web" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.inet0.id
    device_index = 0
  }

  tags = {
    name = "web"
  }
}
