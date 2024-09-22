variable "aws_region" {
  description = "The AWS region to deploy the resources in"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "The CIDR blocks for the public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "The CIDR blocks for the private subnets"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "db_instance_identifier" {
  description = "RDS instance identifier"
  default     = "drupal"
}

variable "db_name" {
  description = "Initial database name for Drupal"
  default     = "drupal"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2023"
  default     = "ami-00f07845aed8c0ee7"
}