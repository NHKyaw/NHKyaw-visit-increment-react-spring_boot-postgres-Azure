# output "ec2_public_ip" {
#   value = aws_eip.visit_record_eip.public_ip
# }

# output "instance_id" {
#   value = aws_instance.visit_record_instance.id
# }

# output "environment" {
#   value = var.environment
# 

output "vm_public_ip" {
  value = azurerm_public_ip.az_visit_increment_public_ip.ip_address
}