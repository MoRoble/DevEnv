###----compute/main.tf ----

# data "aws_ami" "server_ami" {
#   most_recent = true
#   owners = ["099720109477"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }
# }

resource "random_id" "dev_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

## key pair
resource "aws_key_pair" "sweden_key" {
  key_name = "devenv"
  #   key_name   = var.key_name
  #   public_key = file(var.public_key_path)
  public_key = file("devenv.pub")
  # public_key = file("/Users/Mohamed.Roble/Documents/Dev/DevEnv/devenv01.pem")

}

resource "aws_instance" "dev_ec2" {
  #   count         = var.instance_count
  instance_type          = var.instance_type #refer to root/main.tf
  ami                    = data.aws_ami.ubuntu_server.id
  key_name               = aws_key_pair.sweden_key.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  #   vpc_security_group_ids = [var.public_sg]
  subnet_id = aws_subnet.dev_pub_sn1.id
  #   subnet_id              = var.public_subnets[count.index]
  iam_instance_profile = aws_iam_instance_profile.dev_ec2_profile.name
  user_data            = file("userdata.tpl")
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
      hostname = self.public_ip,
      user     = "ubuntu",
      # identityfile = "/Users/Mohamed.Roble/Documents/Dev/DevEnv/devenv01.pem"
      identityfile = "~/.ssh/devenv"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
    # interpreter = ["bash", "-c"]
    # interpreter = ["perl", "-e"]
    # interpreter = ["Powershell", "-Command"] # for windows workstation
  }
}