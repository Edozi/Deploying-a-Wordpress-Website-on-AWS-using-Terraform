variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  description = "VPC cidr block"
}

variable "subnet_cidr_block1" {
  default = "10.0.1.0/24"
  description = "Public subnet cidr block1"
}

variable "subnet_cidr_block2" {
  default = "10.0.2.0/24"
  description = "Public subnet cidr block2"
}

variable "subnet_cidr_block3" {
  default = "10.0.3.0/24"
  description = "Private subnet cidr block1"
}

variable "subnet_cidr_block4" {
  default = "10.0.4.0/24"
  description = "Private subnet cidr block2"
}

variable "availability_zone1" {
  default = "us-east-1a"
  description = "Availability zone 1"
}

variable "availability_zone2" {
  default = "us-east-1b"
  description = "Availability zone 2"
}

variable "all" {
  default = "0.0.0.0/0"
  description = "All variable"
}

variable "https" {
  default = "443"
  description = "https port"
}

variable "http" {
  default = "80"
  description = "http port"
}

variable "ssh" {
  default = "22"
  description = "ssh port"
}

variable "instance_image_id" {
  default = "ami-0a10f74e2469cd8cd"
  description = "Instance AMI ID"
}

variable "instance_type" {
  default = "t2.micro"
  description = "Instance type  "
}
