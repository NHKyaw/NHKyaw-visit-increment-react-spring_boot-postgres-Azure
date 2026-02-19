# environment              = "prod"
# ami_id                   = "ami-08d59269edddde222"
# visit_increment_key_name = "visit_increment"
# vpc_cidr                 = "10.2.0.0/16"
# public_subnet_cidr       = "10.2.1.0/24"
# ssh_cidr                 = ["YOUR_OFFICE_IP/32"]
# instance_type            = "t3.medium"
cidr-env          = "10.0.3.0/24"
environment       = "prod"
vm_size           = "Standard_D4s_v3"
instance_count    = 3
enable_monitoring = true

tags = {
  Environment = "prod"
  ManagedBy   = "terraform"
  Owner       = "team-prod"
  CostCenter  = "67890"
  Backup      = "daily"
}