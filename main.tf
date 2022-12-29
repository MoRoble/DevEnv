##### main.tf 
resource "aws_vpc" "arday_vpc" {
  cidr_block           = "10.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Arday-Main-ec2-VPC"
  }
}

resource "aws_subnet" "arday_public_sn" {
  vpc_id                  = aws_vpc.arday_vpc.id
  cidr_block              = "10.16.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "pub-sn"
  }
}

resource "aws_subnet" "arday_public_sn1" {
  vpc_id                  = aws_vpc.arday_vpc.id
  cidr_block              = "10.16.48.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags = {
    Name = "pub-sn1"
  }
}

resource "aws_internet_gateway" "arday_igw" {
  vpc_id = aws_vpc.arday_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "arday_pub_rt" {
  vpc_id = aws_vpc.arday_vpc.id

  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.arday_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.arday_igw.id
}

resource "aws_route_table_association" "arday_pub_assoc" {
  subnet_id      = aws_subnet.arday_public_sn.id
  route_table_id = aws_route_table.arday_pub_rt.id

}

resource "aws_route_table_association" "arday_sn1_assoc" {
  subnet_id      = aws_subnet.arday_public_sn1.id
  route_table_id = aws_route_table.arday_pub_rt.id
}

resource "aws_security_group" "arday_sg" {
  name        = "dev-sg"
  description = "Developer Security group"
  vpc_id      = aws_vpc.arday_vpc.id

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

# Get the latest Windows Server 2022 AMI
data "aws_ami" "windows_server" {
  most_recent = true
  owners      = ["801119661308"]
  # owners = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}



resource "aws_instance" "arday_ec2" {
  instance_type = "t3.micro"
  ami           = data.aws_ami.windows_server.id
  #   key_name               = aws_key_pair.sweden_key.id
  key_name = "devenv01"
  # key_name               = "oregon"
  vpc_security_group_ids = [aws_security_group.arday_sg.id]
  subnet_id              = aws_subnet.arday_public_sn.id
  get_password_data      = true

  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name = "Windows-server1"
  }

}

# resource "aws_eip" "win_ip" {
#     vpc = true
#     instance = "${aws_instance.arday_ec2.id}"
#   }

# resource "null_resource" "example" {
#   # count = 2

#   triggers = {
#     password = "${rsadecrypt(aws_instance.arday_ec2.*.password_data, file("~/Documents/Dev/keys/devenv01.pem"))}"
#   }
# }

resource "aws_instance" "arday1_ec2" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.windows_server.id
  #   key_name               = aws_key_pair.sweden_key.id
  key_name = "devenv01"
  # key_name               = "oregon"
  vpc_security_group_ids = [aws_security_group.arday_sg.id]
  subnet_id              = aws_subnet.arday_public_sn1.id

  #   user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "Windows-server2"
  }

}