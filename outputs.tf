#### outputs.tf
output "instance_public_dns" {
  value = aws_instance.arday_ec2.public_dns
}
output "instance_public_ip" {
  value = aws_instance.arday_ec2.public_ip
}
output "server1_public_dns" {
  value = aws_instance.arday1_ec2.public_dns
}

# output "Administrator_Password" {
#    value = [
#      for g in aws_instance.arday_ec2 : rsadecrypt(g.password_data,file("~/Documents/Dev/keys/devenv01.pem"))
#    ]
#  }

#  output "Administrator_Password" {
#    value = "${aws_instance.arday_ec2.*.public_ip}" - [
#      for g in aws_instance.arday_ec2 : rsadecrypt(g.password_data,file("~/Documents/Dev/keys/devenv01.pem"))
#    ]
#  }

#  output "Administrator_Password" {
#     value = "${null_resource.example.*.triggers.password}"
# }

# output "password_data" {
#   value="${aws_instance.arday_ec2.password_data}"
# }

output "password_decrypted" {
  value = rsadecrypt(aws_instance.arday_ec2.password_data, file("~/Documents/Dev/keys/arday.pem"))
}