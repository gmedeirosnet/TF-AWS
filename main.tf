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
resource "aws_vpc" "web-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "Main"
  }
}

## SUBNET
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.web-vpc.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    name = "Main"
  }
}

# ## EC2 INSTANCE
# resource "aws_instance" "web" {
#   ami           = "ami-04505e74c0741db8d"
#   instance_type = "t2.micro"

#   tags = {
#     name = "web"
#   }
# }
