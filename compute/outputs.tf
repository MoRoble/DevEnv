output "ec2_ip" {
  value = aws_instance.objs.*.public_ip
}
