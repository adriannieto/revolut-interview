
data "aws_availability_zones" "available" {
}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = local.resource_name_prefix
  }
}

resource "aws_subnet" "private" {
  count             = var.availability_zones_enabled
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name_prefix}-private-${count.index}"
  }
}

resource "aws_subnet" "public" {
  count                   = var.availability_zones_enabled
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.availability_zones_enabled + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.resource_name_prefix}-public-${count.index}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.resource_name_prefix
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_eip" "gw" {
  count      = var.availability_zones_enabled
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${local.resource_name_prefix}-${count.index}"
  }
}

resource "aws_nat_gateway" "gw" {
  depends_on = [
    aws_internet_gateway.gw,
  ]

  count         = var.availability_zones_enabled
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.gw[*].id, count.index)

  tags = {
    Name = "${local.resource_name_prefix}-${count.index}"
  }
}

resource "aws_route_table" "private" {
  count  = var.availability_zones_enabled
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw[*].id, count.index)
  }

  tags = {
    Name = "${local.resource_name_prefix}-private-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.availability_zones_enabled
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}