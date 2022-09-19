#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.dev_vpc.id
}

# output "db_subnet_group_name" {
#   value = aws_db_subnet_group.rds_sng.*.name
# }

output "security_group" {
  value = [aws_security_group.objs["dev_sg"].id]
}

output "dev_role" {
  value = aws_iam_role.dev_wp_role.id
}

output "public_subnets" {
  value = aws_subnet.dev_pub_sn.*.id
}

output "lb_public_subnets" {
  value = aws_subnet.dev_pub_sn[0].id
}

# output "iam_role"{
#   value = aws_iam_role.dev_wp_role.id
# }


