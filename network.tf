# This module is for the networking of VPC: main.


# 1. We attach a NAT gateway to the whole VPC infrastructure.

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}


# 2. We will attach a public subnet inside of the VPC, where we'll define resources.

resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.main
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.main.id
  
  # IP Range of this subnet
  cidr_block = "10.0.1.0/24"
  
  # Data Center of this subnet.
  availability_zone = "us-east-1a"
  
  # Enabling automatic public IP assignment on instance launch!
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet of VPC: main"
  }
}

# 3. Defining a routing table for the public subnet (going through the NAT gateway).
#    Will be mandatory dependable of the presense of VPC and Internet Gateway.
resource "aws_route_table" "main_rt" {
    depends_on = [
      aws_vpc.main,
      aws_internet_gateway.main
    ]
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Routing table for Internet Gateway (main)."
  }  
}

# 4. Association of the routing table to the Public subnet.

resource "aws_route_table_association" "Routing_Table_Association" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.public,
    aws_route_table.main_rt
  ]

# Public Subnet ID
  subnet_id      = aws_subnet.public.id

#  Route Table ID
  route_table_id = aws_route_table.main_rt.id
}


# 5. Reserving an Elastic IP && Adding a NAT GW.
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.Routing_Table_Association
  ]
  vpc = true
}

resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public.id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}


# 6. Activation of security groups for ports 80,443

# A. VPC-SG attached
resource "aws_security_group" "main_sg" {
  name        = "allow_80_443"
  description = "VPC security group"
  vpc_id      = aws_vpc.main.id


# B. Inbound rules for 80,443 - from VPC to Internet. 
#    Protocol 6 is tcp. for all protocols -1, but must all ports be 0.
  ingress {
    description      = "https from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = 6
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = 6
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

# C. Outbound rules for 80,443 - from Internet to VPC. 
#    Protocol 6 is tcp. for all protocols -1, but must all ports be 0.
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = 6
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = 6
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
