# -- networking/main.tf ---

data "aws_availability_zones" "az" {}

resource "random_integer" "random" {
  min = 1
  max = 10
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.az.names
  result_count = var.max_subnets
}

## VPC ----

resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    # Name = "Dev-Main-VPC"
    Name = "Dev_vpc-${random_integer.random.id}"
  }
  lifecycle {
    # the igw doesn't know where to go,
    # this lifecycle will create new vpc before existing vpc destroys so igw can reside
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "dev_pub_assoc" {
  count     = var.pub_sn_count
  subnet_id = aws_subnet.dev_pub_sn.*.id[count.index]
  # subnet_id      = aws_subnet.dev_pub_sn1.id
  route_table_id = aws_route_table.dev_pub_rt.id
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

resource "aws_route" "default_rt" {
  route_table_id         = aws_route_table.dev_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}

resource "aws_default_route_table" "private_rt" {
  #assigning default rt created by vpc to make our own default rt
  default_route_table_id = aws_vpc.dev_vpc.default_route_table_id

  tags = {
    Name = "dev-pr-rt"
  }
}

resource "aws_security_group" "objs" {
  for_each    = var.main_sg
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.dev_vpc.id


  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group" "dev_sg_wp" {
#   vpc_id = aws_vpc.dev_vpc.id

#   for_each    = var.main_sgs
#   name        = each.value.name
#   description = each.value.description

#   dynamic "ingress" {
#     for_each = each.value.ingress
#     content {
#       description = ingress.value.description
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

# resource "aws_security_group" "dev_db_sg" {
#   vpc_id = aws_vpc.dev_vpc.id


#   for_each    = var.main_sgs
#   name        = each.value.name
#   description = each.value.description

#   dynamic "ingress" {
#     for_each = each.value.ingress
#     content {
#       description = ingress.value.description
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

# resource "aws_security_group" "dev_efs_sg" {
#   vpc_id = aws_vpc.dev_vpc.id

#   for_each    = var.main_sgs
#   name        = each.value.name
#   description = each.value.description

#   dynamic "ingress" {
#     for_each = each.value.ingress
#     content {
#       description = ingress.value.description
#       from_port   = ingress.value.from
#       to_port     = ingress.value.to
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }
# }

### --- Subnets ----

resource "aws_subnet" "dev_pub_sn" {
  count                   = var.pub_sn_count
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.pub_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "pub_sn_${count.index + 1}"
  }
}


resource "aws_subnet" "dev_app_sn" {
  count             = var.app_sn_count
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.pub_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "app_sn_${count.index + 1}"
  }
}

resource "aws_subnet" "dev_db_sn" {
  count             = var.db_sn_count
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.pub_cidrs[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "db_sn_${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "rds_sng" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "rds_subnetgroup"
  subnet_ids = aws_subnet.dev_db_sn.*.id
  tags = {
    name = "db-sng"
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
  name = "dev_role"
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

