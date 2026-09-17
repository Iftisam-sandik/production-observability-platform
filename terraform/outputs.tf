output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "ID of public subnet A"
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "ID of public subnet B"
  value       = aws_subnet.public_b.id
}

output "public_subnet_a_az" {
  description = "Availability Zone of public subnet A"
  value       = aws_subnet.public_a.availability_zone
}

output "public_subnet_b_az" {
  description = "Availability Zone of public subnet B"
  value       = aws_subnet.public_b.availability_zone
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
