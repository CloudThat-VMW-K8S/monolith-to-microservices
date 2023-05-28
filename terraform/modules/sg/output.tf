output "ec2_sg_id" {
  description = "ID of the created security group"
  value       = aws_security_group.ec2_sg.id
}
