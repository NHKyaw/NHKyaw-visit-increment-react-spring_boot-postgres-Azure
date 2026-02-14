resource "aws_vpc" "visit_record_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name        = "visit-record-vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "visit_record_gw" {
  vpc_id = aws_vpc.visit_record_vpc.id

  tags = {
    Name        = "visit-record-igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "visit_record_subnet" {
  vpc_id                  = aws_vpc.visit_record_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name        = "visit-record-subnet-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.visit_record_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.visit_record_gw.id
  }

  tags = {
    Name        = "visit-record-public-rt-${var.environment}"
    Environment = var.environment
  }
}
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.visit_record_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "visit_record_sg" {
  name   = "visit-record-sg-${var.environment}"
  vpc_id = aws_vpc.visit_record_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "visit-record-sg-${var.environment}"
    Environment = var.environment
  }
}


locals {
  instance_type_map = {
    dev  = "t2.micro"
    uat  = "t2.small"
    prod = "t3.medium"
  }

  instance_type = local.instance_type_map[var.environment]
}

resource "aws_instance" "visit_record_instance" {
  ami           = var.ami_id
  instance_type = local.instance_type
  key_name      = var.visit_increment_key_name
  user_data_replace_on_change = true


  network_interface {
    network_interface_id = aws_network_interface.visit_record_eni.id
    device_index         = 0
  }

  user_data = file("userdata.sh")

  tags = {
    Name = "visit-record-${var.environment}"
  }
}


resource "aws_network_interface" "visit_record_eni" {
  subnet_id       = aws_subnet.visit_record_subnet.id
  security_groups = [aws_security_group.visit_record_sg.id]

  tags = {
    Name        = "visit-record-eni-${var.environment}"
    Environment = var.environment
  }
}


resource "aws_eip" "visit_record_eip" {
  domain = "vpc"
  tags = {
    Name        = "visit-record-eip-${var.environment}"
    Environment = var.environment
  }
}


resource "aws_eip_association" "eip_assoc" {
  network_interface_id = aws_network_interface.visit_record_eni.id
  allocation_id        = aws_eip.visit_record_eip.id
  depends_on = [
    aws_instance.visit_record_instance
  ]
}

terraform {
  backend "s3" {
    bucket  = "visit-record-terraform-state"
    key     = "env/${var.environment}/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}