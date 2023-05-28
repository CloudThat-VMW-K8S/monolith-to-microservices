output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.vpc.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet[0].id  # Use the appropriate index if there are multiple subnets
}
