# VPC
resource "aws_vpc" "quiter_vpc" {
  provider = aws.client
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.client}-${var.environment}-vpc"
    Environment = var.environment
    project = "quiter"
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  provider = aws.client
  vpc        = true
  depends_on = [ aws_internet_gateway.ig ]
  tags = {
    project = "quiter"
  }
}

####################
## Public subnets ##
####################

// Public subnet 1
resource "aws_subnet" "public_subnet_1" {
  provider = aws.client
  vpc_id                  = aws_vpc.quiter_vpc.id
  cidr_block              = var.public_subnet_1["cidr_block"]
  availability_zone       = var.public_subnet_1["az"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${var.public_subnet_1["az"]}"
    Environment = "${var.environment}"
  }
}

// Public subnet 2
resource "aws_subnet" "public_subnet_2" {
  provider = aws.client
  vpc_id                  = aws_vpc.quiter_vpc.id
  cidr_block              = var.public_subnet_2["cidr_block"]
  availability_zone       = var.public_subnet_2["az"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${var.public_subnet_2["az"]}"
    Environment = "${var.environment}"
  }
}

// Public subnet 3
resource "aws_subnet" "public_subnet_3" {
  provider = aws.client
  vpc_id                  = aws_vpc.quiter_vpc.id
  cidr_block              = var.public_subnet_3["cidr_block"]
  availability_zone       = var.public_subnet_3["az"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-public-subnet-${var.public_subnet_3["az"]}"
    Environment = "${var.environment}"
  }
}

# Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  provider = aws.client
  vpc_id                  = aws_vpc.quiter_vpc.id
  cidr_block              = var.private_subnet_1["cidr_block"]
  availability_zone       = var.private_subnet_1["az"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-private-subnet-${var.private_subnet_1["az"]}"
    Environment = "${var.environment}"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  provider = aws.client
  vpc_id                  = aws_vpc.quiter_vpc.id
  cidr_block              = var.private_subnet_2["cidr_block"]
  availability_zone       = var.private_subnet_2["az"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-private-subnet-${var.private_subnet_2["az"]}"
    Environment = "${var.environment}"
  }
}

# Private Subnet 3
resource "aws_subnet" "private_subnet_3" {
  provider = aws.client
  vpc_id                  = aws_vpc.quiter_vpc.id
  cidr_block              = var.private_subnet_3["cidr_block"]
  availability_zone       = var.private_subnet_3["az"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-private-subnet-${var.private_subnet_3["az"]}"
    Environment = "${var.environment}"
  }
}

####################
## Routing tables ##
####################

# Routing table for Private Subnet
resource "aws_route_table" "private" {
  provider = aws.client
  vpc_id = aws_vpc.quiter_vpc.id

  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

# Routing table for Public Subnet
resource "aws_route_table" "public" {
  provider = aws.client
  vpc_id = aws_vpc.quiter_vpc.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  provider = aws.client
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for VPN Gateway
resource "aws_route" "private_vpn_gateway" {
  provider = aws.client
  count                   = length(var.client_subnets_ranges)
  route_table_id         = aws_route_table.private.id
  destination_cidr_block  = element(var.client_subnets_ranges, count.index)
  gateway_id              = aws_vpn_gateway.vpn_gw.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  provider = aws.client  
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  # nat_gateway_id         = aws_nat_gateway.nat.id
  gateway_id             = aws_internet_gateway.ig.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public_1" {
  provider = aws.client
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  provider = aws.client
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  provider = aws.client
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  provider = aws.client
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  provider = aws.client
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_3" {
  provider = aws.client
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private.id
}

## VPN Conection
resource "aws_vpn_connection" "client_vpn_conection" {
  provider = aws.client
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  type                = "ipsec.1"
  local_ipv4_network_cidr = var.client_subnets_ranges[0]
  remote_ipv4_network_cidr = var.vpc_cidr_block

  static_routes_only = var.vpn-statica

  tunnel1_ike_versions = ["ikev1", "ikev2"]
  tunnel1_phase1_dh_group_numbers = ["2"]
  tunnel1_phase1_encryption_algorithms = ["AES128", "AES256"]
  tunnel1_phase1_integrity_algorithms = ["SHA1", "SHA2-256"]
  tunnel1_phase1_lifetime_seconds = "28800"
  tunnel1_phase2_dh_group_numbers = ["2"]
  tunnel1_phase2_encryption_algorithms = ["AES128", "AES256"]
  tunnel1_phase2_integrity_algorithms = ["SHA1", "SHA2-256"]
  tunnel1_phase2_lifetime_seconds = "3600"
  tunnel1_dpd_timeout_action = "restart"
  tunnel1_startup_action = "start"

  tunnel2_ike_versions = ["ikev1", "ikev2"]
  tunnel2_phase1_dh_group_numbers = ["2"]
  tunnel2_phase1_encryption_algorithms = ["AES128", "AES256"]
  tunnel2_phase1_integrity_algorithms = ["SHA1", "SHA2-256"]
  tunnel2_phase1_lifetime_seconds = "28800"
  tunnel2_phase2_dh_group_numbers = ["2"]
  tunnel2_phase2_encryption_algorithms = ["AES128", "AES256"]
  tunnel2_phase2_integrity_algorithms = ["SHA1", "SHA2-256"]
  tunnel2_phase2_lifetime_seconds = "3600"
  tunnel2_dpd_timeout_action = "restart"
  tunnel2_startup_action = "start"

  tags = {
    Name = "vpn-1"
    project = "quiter"
  }
}

resource "aws_vpn_connection_route" "coyoacan" {
  count = var.vpn-statica ? 1 : 0
  provider = aws.client
  destination_cidr_block = var.client_subnets_ranges[0]
  vpn_connection_id      = aws_vpn_connection.client_vpn_conection.id
}

/**
* GRUPOS DE SEGURIDAD
**/

resource "aws_security_group" "totalcloud-support" {
  provider = aws.client
  name        = "totalcloud-support"
  description = "Habilita al equipo de Totalcloud para dar soporte tecnico"
  vpc_id      = aws_vpc.quiter_vpc.id

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"
    cidr_blocks      = ["200.188.7.162/32"]
    description = "Oficina Totalcloud"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Environment = "${var.environment}"
    project = "quiter"
    Name        = "totalcloud-support"
  }
}

resource "aws_security_group" "quiter_sg" {
  provider = aws.client
  name        = "quiter-sg"
  description = "Habilita el trafico necesario entre los servidores de Quiter y la red del cliente"
  vpc_id      = aws_vpc.quiter_vpc.id
  depends_on = [ aws_vpc.quiter_vpc ]
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Environment = "${var.environment}"
    project = "quiter"
  }
}

resource "aws_security_group_rule" "ftp" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 21
  to_port           = 21
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "ssh-tc-support" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id       = aws_security_group.totalcloud-support.id
}
resource "aws_security_group_rule" "ssh-1" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
}
resource "aws_security_group_rule" "ssh" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "http" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "https" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "smtp" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 465
  to_port           = 465
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "quiter-11" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 6080
  to_port           = 6080
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "quiter-1" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 6080
  to_port           = 6080
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "quiter-2" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}
resource "aws_security_group_rule" "quiter-33" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  self              = true
}
resource "aws_security_group_rule" "quiter-3" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}
resource "aws_security_group_rule" "quiter-4" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 31438
  to_port           = 31438
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}
resource "aws_security_group_rule" "quiter-5" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 53229
  to_port           = 53229
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}
resource "aws_security_group_rule" "quiter-6" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 56955
  to_port           = 56955
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "quiter-7" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 60502
  to_port           = 60502
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}

resource "aws_security_group_rule" "quiter-8" {
  provider = aws.client
  security_group_id = aws_security_group.quiter_sg.id
  count             = length(var.client_subnets_ranges)
  type              = "ingress"
  from_port         = 63801
  to_port           = 63801
  protocol          = "tcp"
  cidr_blocks       = [element(var.client_subnets_ranges, count.index)]
}
