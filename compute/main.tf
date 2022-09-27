###----compute/main.tf ----

resource "random_id" "dev_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}
## SSM parameters for the  key pair 
resource "aws_ssm_parameter" "key_path" {
  name        = "/dev/global/instance/key-pair"
  description = "The ssh key pair"
  type        = "SecureString"
  value       = local.tmp.ssmp_placeholder_default_value
  tags        = var.devtags
  lifecycle {
    ignore_changes = [value]
  }
}
## key pair
resource "aws_key_pair" "kep_pair" {
  key_name   = var.key_name
  # public_key = aws_ssm_parameter.key_path.value
  public_key = file("/Users/Mohamed.Roble/Documents/Dev/keys/devenv.pub")

}

resource "aws_instance" "objs" {
  count                  = var.instance_count
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu_server.id
  key_name               = aws_key_pair.kep_pair.id
  vpc_security_group_ids = var.security_group
  subnet_id              = var.pub_sn[count.index]
  # iam_instance_profile   = aws_iam_instance_profile.dev_ec2_profile.name
  user_data = file("./compute/userdata.tpl")
  # user_data              = ""

  root_block_device {
    volume_size = var.vol_size
  }
  tags = {
    Name = local.tmp.dev_generic_name["dev"]

  }



  provisioner "local-exec" {
    command = templatefile("./compute/${var.host_os}-ssh-config.tpl", {
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