###----compute/main.tf ----

resource "random_id" "dev_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

## key pair
resource "aws_key_pair" "sweden_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

}

resource "aws_instance" "objs" {
  count                  = var.instance_count
  instance_type          = var.instance_type #refer to root/main.tf
  ami                    = data.aws_ami.ubuntu_server.id
  key_name               = aws_key_pair.sweden_key.id
  vpc_security_group_ids = var.security_group
  subnet_id              = var.pub_sn[count.index]
  # iam_instance_profile   = aws_iam_instance_profile.dev_ec2_profile.name
  user_data = file("./compute/userdata.tpl")
  # user_data              = ""

  root_block_device {
    # volume_size = 23
    volume_size = var.vol_size
  }
  tags = {
    Name = "Ubuntu-server"
    # Name = "dev_node-${random_id.mtc_node_id[count.index].dec}"
  }



  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/devenv"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
    # interpreter = ["bash", "-c"]
    # interpreter = ["perl", "-e"]
    # interpreter = ["Powershell", "-Command"] # for windows workstation
  }
}


## intance profile

# resource "aws_iam_instance_profile" "dev_ec2_profile" {
#   name = var.instance_profile
#   role = var.iam_role
# }