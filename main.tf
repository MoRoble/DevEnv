resource "aws_vpc" "dev_ec2_vpc" {
  cidr_block           = "10.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev-Main-ec2-VPC"
  }
}

resource "aws_subnet" "dev_public_sn" {
  vpc_id                  = aws_vpc.dev_ec2_vpc.id
  cidr_block              = "10.16.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "pub-sn"
  }
}

resource "aws_subnet" "dev_public_sn1" {
  vpc_id                  = aws_vpc.dev_ec2_vpc.id
  cidr_block              = "10.16.48.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags = {
    Name = "pub-sn1"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_ec2_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dev_pub_rt" {
  vpc_id = aws_vpc.dev_ec2_vpc.id

  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}

resource "aws_route_table_association" "dev_pub_assoc" {
  subnet_id      = aws_subnet.dev_public_sn.id
  route_table_id = aws_route_table.dev_pub_rt.id

}

resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Developer Security group"
  vpc_id      = aws_vpc.dev_ec2_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # cidr_blocks = ["1.1.1.1/32"] # /32 to ensure only that IP is allowed
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "sweden_key" {
  key_name = "devenv"
  # key_name = "devenv01"
  # public_key = file("~/.ssh/devenv.pub")
  # public_key = file("devenv.pub")
  public_key = file("/Users/Mohamed.Roble/Documents/Dev/keys/devenv.pub")

}

resource "aws_instance" "dev_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu_server.id
  key_name               = aws_key_pair.sweden_key.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.dev_public_sn.id

  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 23
  }

  tags = {
    Name = "Ubuntu-server"
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

resource "aws_efs_file_system" "dev_efs" {
  creation_token = "dev-files"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # number_of_mount_targets = 2

  tags = {
    Name = "Dev-files1"
  }
}