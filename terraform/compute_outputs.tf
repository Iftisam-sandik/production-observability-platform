output "app_server_1_public_ip" {
  value = aws_instance.app_1.public_ip
}

output "app_server_1_private_ip" {
  value = aws_instance.app_1.private_ip
}

output "app_server_2_public_ip" {
  value = aws_instance.app_2.public_ip
}

output "app_server_2_private_ip" {
  value = aws_instance.app_2.private_ip
}

output "db_server_public_ip" {
  value = aws_instance.db.public_ip
}

output "db_server_private_ip" {
  value = aws_instance.db.private_ip
}

output "monitoring_server_public_ip" {
  value = aws_instance.monitoring.public_ip
}

output "monitoring_server_private_ip" {
  value = aws_instance.monitoring.private_ip
}
