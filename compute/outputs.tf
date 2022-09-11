output "ec2_ip" {
  value = {
    ip_address    = aws_instance.objs.*.public_ip
  #   instance_name = aws_instance.objs.*.name
   }
}
