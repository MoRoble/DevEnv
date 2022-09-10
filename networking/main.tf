# -- networking/main.tf ---

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 10
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

## VPC ----

resource "aws_vpc" "dev_vpc" {
  #   cidr_block = "10.16.0.0/16"
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    # Name = "Dev-Main-VPC"
    Name = "Dev_vpc-${random_integer.random.id}"
  }
  lifecycle {
    # the igw doesn't know where to go,
    # this lifecycle will create new vpc before it destroys so igw can reside
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "dev_pub_assoc" {
  #   count          = var.public_sn_count
  #   subnet_id      = aws_subnet.public_sn.*.id[count.index]
  subnet_id      = aws_subnet.dev_pub_sn1.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.mtc_vpc.id

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

resource "aws_route" "default_rt" {
  route_table_id         = aws_route_table.dev_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = aws_vpc.mtc_vpc.default_route_table_id

  tags = {
    Name = "private-rt"
  }
}

# resource "aws_security_group" "mtc_sg" {
#   for_each    = var.security_groups
#   name        = each.value.name
#   description = each.value.description
#   # name        = "public_sg"
#   # description = "security gourp for public access"
#   vpc_id = aws_vpc.mtc_vpc.id
#   dynamic "ingress" {
#     for_each = each.value.ingress
#     content {
#       from_port   = ingress.value.from
#       to_port     = ingress.value.to
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Dev main public Security group"
  vpc_id      = aws_vpc.dev_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # cidr_blocks = ["1.1.1.1/32"] # /32 to ensure only that IP is allowed
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [var.access_ip] #to stop spreading IPs in your code
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

### --- Subnets ----

resource "aws_subnet" "dev_pub_sn1" {
  count  = length(var.pub_cidrs)
  vpc_id = aws_vpc.dev_vpc.id
  #   cidr_block              = "10.16.0.0/20"
  cidr_block              = var.pub_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["us-west-2a", "us-west-2b", "us-west-2c"][count.index]
  #   availability_zone       = "us-west-2a"

  #   count = var.public_sn_count
  #   # count = length(var.public_cidrs)
  #   vpc_id                  = aws_vpc.mtc_vpc.id
  #   cidr_block              = var.public_cidrs[count.index]
  #   map_public_ip_on_launch = true
  #   availability_zone       = random_shuffle.az_list.result[count.index]
  #   # availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "pub_snA_${count.index + 1}"
  }
}

# resource "aws_subnet" "private_sn" {
#   count             = var.private_sn_count
#   vpc_id            = aws_vpc.mtc_vpc.id
#   cidr_block        = var.private_cidrs[count.index]
#   availability_zone = random_shuffle.az_list.result[count.index]

#   tags = {
#     Name = "pvt_sn_${count.index + 1}"
#   }
# }

resource "aws_subnet" "dev_app_sn1" {
  count             = length(var.app_cidrs)
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.pub_cidrs[count.index]
  availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c"][count.index]

  tags = {
    Name = "app_snA_${count.index + 1}"
  }
}

resource "aws_subnet" "dev_db_sn1" {
  count             = length(var.db_cidrs)
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.pub_cidrs[count.index]
  availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c"][count.index]

  tags = {
    Name = "db_snA_${count.index + 1}"
  }
}

# resource "aws_subnet" "dev_pub_sn2" {
#   vpc_id                  = aws_vpc.dev_vpc.id
#   cidr_block              = "10.16.16.0/20"
#   map_public_ip_on_launch = true
#   availability_zone       = "us-west-2b"

#   tags = {
#     Name = "pub-snB"
#   }
# }


# resource "aws_subnet" "dev_pub_sn3" {
#   vpc_id                  = aws_vpc.dev_vpc.id
#   cidr_block              = "10.16.32.0/20"
#   map_public_ip_on_launch = true
#   availability_zone       = "us-west-2c"

#   tags = {
#     Name = "pub-snC"
#   }
# }

# resource "aws_subnet" "dev_app_sn1" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = "10.16.48.0/20"
#   availability_zone = "us-west-2a"

#   tags = {
#     Name = "pr-snA"
#   }
# }

# resource "aws_subnet" "dev_app_sn2" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = "10.16.64.0/20"
#   availability_zone = "us-west-2b"

#   tags = {
#     Name = "pr-snB"
#   }
# }

# resource "aws_subnet" "dev_app_sn3" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = "10.16.80.0/20"
#   availability_zone = "us-west-2c"

#   tags = {
#     Name = "pr-snC"
#   }
# }

# resource "aws_subnet" "dev_db_sn1" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = "10.16.96.0/20"
#   availability_zone = "us-west-2a"

#   tags = {
#     Name = "db-snA"
#   }
# }

# resource "aws_subnet" "dev_db_sn2" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = "10.16.112.0/20"
#   availability_zone = "us-west-2b"

#   tags = {
#     Name = "db-snB"
#   }
# }

# resource "aws_subnet" "dev_db_sn3" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = "10.16.128.0/20"
#   availability_zone = "us-west-2c"

#   tags = {
#     Name = "db-snC"
#   }
# }


resource "aws_db_subnet_group" "rds_sng" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "rds_subnetgroup"
  subnet_ids = aws_subnet.private_sn.*.id
  tags = {
    name = "rds-sng"
  }
}

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

## intance profile

resource "aws_iam_instance_profile" "dev_ec2_profile" {
  name = "instance_profile"
  role = aws_iam_role.dev_wp_role.name
}