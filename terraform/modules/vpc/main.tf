# =========================
# VPC
# =========================

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}


# =========================
# Internet Gateway
# =========================

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}


# =========================
# Public Subnets
# =========================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
  }
}


# =========================
# Private Subnets
# =========================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}


# =========================
# Public Route Table
# =========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}


# =========================
# Public Route Table Associations
# =========================

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

/*
Elastic IP provides a static public IP address to the NAT Gateway, while the NAT Gateway allows resources in private subnets to access the internet without giving those resources public IP addresses.
*/

# =========================
# Elastic IP for NAT Gateway
# =========================

resource "aws_eip" "nat" {
  domain = "vpc" # Create this Elastic IP for use with resources inside a VPC.

  tags = {
    Name = "${var.project_name}-nat-eip" 
  }
}


# =========================
# NAT Gateway
# =========================

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id # allocation_id tells the NAT Gateway which Elastic IP should be attached to it.

  # NAT Gateway MUST be in a PUBLIC subnet, 
  subnet_id = aws_subnet.public[0].id
/*
one NAT Gateway is enough to serve multiple private subnets. The NAT Gateway itself does not need to be created in every subnet.
The NAT Gateway is sitting in the public subnet, and it sends the traffic through the Internet Gateway.
*/
  depends_on = [
    aws_internet_gateway.this
  ]
/*
Why not put NAT Gateway in a private subnet?
Because the NAT Gateway itself needs a path to the internet. So it must be publics subnet
Your NAT Gateway is in a public subnet, and for that subnet to actually have internet connectivity, the VPC needs its Internet Gateway.
*/
  tags = {
    Name = "${var.project_name}-nat"
  }
}


# =========================
# Private Route Table
# =========================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}


# =========================
# Private Route Table Associations
# =========================

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
