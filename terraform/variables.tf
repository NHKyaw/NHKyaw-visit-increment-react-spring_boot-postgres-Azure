variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be dev, uat, or prod"
  }
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "ami_id" {
  type = string
}

variable "visit_increment_key_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "ssh_cidr" {
  type = list(string)
}
