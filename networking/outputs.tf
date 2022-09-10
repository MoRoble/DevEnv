#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.dev_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_sng.*.name
}

output "db_security_group" {
  value = [aws_security_group.dev_sg["rds"].id]
}


