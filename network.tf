# Internet gateway for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ecs-vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.ecs-vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${var.app_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ecs-vpc.id
  count                   = length(var.public_subnets)
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecs-vpc.id

  tags = {
    Name        = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
# Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "eip" {
  count      = length(var.private_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name        = "${var.app_name}-eip"
    Environment = var.app_environment
  }
}
resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.private_subnets)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  tags = {
    Name        = "${var.app_name}-nat-gateway"
    Environment = var.app_environment
  }
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.ecs-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }
  tags = {
    Name        = "${var.app_name}-routing-table-private"
    Environment = var.app_environment
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# VPC Endpoints Interface to talk to other AWS Services not in the VPC
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.ecs-vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private[0].id]
  tags = {
    Name        = "${var.app_name}-s3-endpoint"
    Environment = var.app_environment
  }
}
resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  vpc_id              = aws_vpc.ecs-vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ecs-sg.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = {
    Name        = "${var.app_name}-ecs-dkr-endpoint"
    Environment = var.app_environment
  }
}
resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  vpc_id              = aws_vpc.ecs-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecs-sg.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = {
    Name        = "${var.app_name}-ecr-api-endpoint"
    Environment = var.app_environment
  }
}
resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id              = aws_vpc.ecs-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecs-sg.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = {
    Name        = "${var.app_name}-ecs-agent-endpoint"
    Environment = var.app_environment
  }
}
resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id              = aws_vpc.ecs-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.ecs-sg.id]
  subnet_ids          = aws_subnet.private.*.id
  tags = {
    Name        = "${var.app_name}-ecs-telementry-endpoint"
    Environment = var.app_environment
  }
}