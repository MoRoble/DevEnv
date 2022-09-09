## Policy document
data "aws_iam_policy_document" "dev_policy_doc" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess",
      # - "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    ]
  }
}

## VPC 

resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev-Main-VPC"
  }
}

resource "aws_subnet" "dev_pub_sn1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.16.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "pub-snA"
  }
}

resource "aws_subnet" "dev_pub_sn2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.16.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags = {
    Name = "pub-snB"
  }
}

resource "aws_subnet" "dev_pub_sn3" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.16.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2c"

  tags = {
    Name = "pub-snC"
  }
}
##Private subnets
resource "aws_subnet" "dev_app_sn1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.16.48.0/20"
  availability_zone = "us-west-2a"

  tags = {
    Name = "pr-snA"
  }
}

resource "aws_subnet" "dev_app_sn2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.16.64.0/20"
  availability_zone = "us-west-2b"

  tags = {
    Name = "pr-snB"
  }
}

resource "aws_subnet" "dev_app_sn3" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = "us-west-2c"

  tags = {
    Name = "pr-snC"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dev_pub_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "pub-rt"
  }
}

### DB subnets

resource "aws_subnet" "dev_db_sn1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.16.96.0/20"
  availability_zone = "us-west-2a"

  tags = {
    Name = "db-snA"
  }
}



resource "aws_subnet" "dev_db_sn2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.16.112.0/20"
  availability_zone = "us-west-2b"

  tags = {
    Name = "db-snB"
  }
}


resource "aws_subnet" "dev_db_sn3" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.16.128.0/20"
  availability_zone = "us-west-2c"

  tags = {
    Name = "db-snC"
  }
}



resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}

resource "aws_route_table_association" "dev_pub_assoc" {
  subnet_id      = aws_subnet.dev_pub_sn1.id
  route_table_id = aws_route_table.dev_pub_rt.id

}

resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Developer Security group"
  vpc_id      = aws_vpc.dev_vpc.id

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

resource "aws_security_group" "dev_sg_wp" {
  name        = "dev-sg-wp"
  description = "Developer WordPress & LB Security group"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "Allow http ipv4 traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ssh ipv4 traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dev_db_sg" {
  name        = "dev-db-sg"
  description = "Dev DB  Security group"
  vpc_id      = aws_vpc.dev_vpc.id

  # security_group_id = aws_security_group.dev_sg_wp.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "To allow db traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dev_efs_sg" {
  name        = "dev-efs-sg"
  description = "Dev efs Security group"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "To allow NFS/efs IPv4 traffic"
  }
}

### I am role


resource "aws_iam_role" "dev_wp_role" {
  name = "wp_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowWordPressApplication"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "wp_role"
  }
}

## I am policy

resource "aws_iam_policy" "dev_wp_role" {
  name        = "dev-wp"
  path        = "/"
  description = "A policy for our role"
  policy      = data.aws_iam_policy_document.dev_policy_doc.json


}



## Policy attachement

resource "aws_iam_role_policy_attachment" "dev-assoc" {
  role       = aws_iam_role.dev_wp_role.name
  policy_arn = aws_iam_policy.dev_wp_role.arn
}
## key pair
resource "aws_key_pair" "sweden_key" {
  key_name = "devenv"
  # key_name = "devenv01"
  # public_key = file("~/.ssh/devenv.pub")
  public_key = file("devenv.pub")
  # public_key = file("/Users/Mohamed.Roble/Documents/Dev/DevEnv/devenv01.pem")

}

## intance profile

resource "aws_iam_instance_profile" "dev_ec2_profile" {
  name = "instance_profile"
  role = aws_iam_role.dev_wp_role.name
}



resource "aws_instance" "dev_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu_server.id
  key_name               = aws_key_pair.sweden_key.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.dev_pub_sn1.id
  iam_instance_profile   = aws_iam_instance_profile.dev_ec2_profile.name

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