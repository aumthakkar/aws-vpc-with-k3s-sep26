resource "random_integer" "randint" {
  min = 1
  max = 10
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-vpc-${random_integer.randint.result}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names

  result_count = 10
}

resource "aws_subnet" "my_public_subnets" {
  count = var.public_subnet_count

  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = local.public_subnet_cidr_block[count.index]

  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "my_public_route_table_association" {
  count = var.public_subnet_count

  route_table_id = aws_route_table.my_public_route_table.id
  subnet_id      = aws_subnet.my_public_subnets[count.index].id
}

resource "aws_eip" "my_nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_nat_gateway_eip.id

  subnet_id = aws_subnet.my_public_subnets[0].id

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
}

resource "aws_subnet" "my_private_subnets" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = random_shuffle.az_list.result[count.index]

  map_public_ip_on_launch = false
  cidr_block              = local.private_subnet_cidr_block[count.index]

  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
  }
}


resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "${var.name_prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "my_private_route_table_association" {
  count = var.private_subnet_count

  route_table_id = aws_route_table.my_private_route_table.id
  subnet_id      = aws_subnet.my_private_subnets[count.index].id
}

resource "aws_security_group" "my_security_groups" {
  for_each = local.my_security_groups

  vpc_id = aws_vpc.my_vpc.id

  name        = each.value.name
  description = each.value.description

  tags = each.value.tags

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      cidr_blocks = ingress.value.cidr_blocks
      protocol    = ingress.value.protocol
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "${var.name_prefix}-db-subnet-group"

  subnet_ids = aws_subnet.my_private_subnets[*].id

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }

}

