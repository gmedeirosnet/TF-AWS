provider "aws" {
  region  = "us-east-1"
  // version = "~> 4.11.0"
}

## NETWORK


## INSTANCE
resource "aws_instance" "web" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name      = "tf-aws"

  security_groups = [aws_security_group.web.name]

  tags = {
    WebServer = "WebServer"
  }
}

## SECURITY GROUPS
resource "aws_security_group" "web" {
  name        = "web-security-group"
  description = "Allow access to web server"

  ingress {
    description = "Allow SSH"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    // ipv6_cidr_blocks = [ "value" ]
    // prefix_list_ids = [ "value" ]
    protocol        = "tcp"
    security_groups = ["aws_security_group.web.name"]
    // self = false
    to_port = 22
  }
}

## I DONT KNOW... YET
output "instance_public_dns" {
  value = "aws_instance.web.public_dns"
}