output "ec2_ip" {
  value = aws_instance.dev_ec2.public_ip
}