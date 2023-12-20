# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  provider = aws.client
  vpc_id = aws_vpc.quiter_vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    project = "quiter"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  provider = aws.client
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
    project = "quiter"
  }
}

# VPN Gateway 
resource "aws_vpn_gateway" "vpn_gw" {
provider = aws.client
  vpc_id = aws_vpc.quiter_vpc.id

  tags = {
    Name = "${var.client}-${var.environment}"
    project = "quiter"
  }
}

# Customer Gateway
resource "aws_customer_gateway" "customer_gateway" {
  provider = aws.client
  bgp_asn    = 65000
  ip_address = var.client_public_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.client}-client-gateway"
    project = "quiter"
  }
}
