provider "aws" {
  region = "us-east-1"
  // version = "~> 4.11.0"
}

## NETWORK
## VPC, SUBNETs, and IPs
resource "aws_vpc" "web-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    name = "WebServer"
  }
}

resource "aws_subnet" "web-subnet" {
  vpc_id            = aws_vpc.web-vpc
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-east-1"

  tags = {
    name = "WebServer"
  }

}

resource "aws_network_interface" "foo" {
  subnet_id  = aws_instance.web
  private_ip = "172.16.0.1"

  tags = {
    name = "Primary_network_interface"
  }
}

## SECURITY GROUPS
## 
resource "aws_security_group" "web" {
  name        = "web-security-group"
  description = "Allow access to web server"

  ingress {
    description      = "Allow SSH"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    // prefix_list_ids = [ "value" ]
    protocol        = "tcp"
    security_groups = ["aws_security_group.web.name"]
    // self = false
    to_port = 22
  }
}

## INSTANCE
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "web" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name      = "tf-aws"

  security_groups = [aws_security_group.web.name]

  tags = {
    WebServer = "WebServer"
  }
}

output "instance_public_dns" {
  value = "aws_instance.web.public_dns"
}