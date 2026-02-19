variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be dev, uat, or prod"
  }
}

# #### For AWS ####
# variable "aws_region" {
#   type    = string
#   default = "ap-southeast-1"
# }

# variable "ami_id" {
#   type = string
# }

# variable "visit_increment_key_name" {
#   type = string
# }

# variable "vpc_cidr" {
#   type = string
# }

# variable "public_subnet_cidr" {
#   type = string
# }

# variable "ssh_cidr" {
#   type = list(string)
# }


#### For Azure #####
variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "th-lab_group"
}

variable "vm_admin_username" {
  default = "nhkyaw"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "vm-net-cidr" {
  description = "VM network CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidr-env" {
  description = "Environment CIDR block"
}

variable "vm_size" {
  description = "Virtual machine size"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

