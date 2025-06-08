# ---------------------------------------------------------------------------------------------------------------------
# AWS NETWORKING INFRASTRUCTURE
# This Terraform configuration creates a VPC with public and private subnets for a multi-tier architecture
# The network design includes:
# - A VPC with DNS support enabled
# - One public subnet for internet-facing resources
# - Two private subnets (one for AI workloads, one for databases)
# - Internet Gateway for public internet access
# - NAT Gateway for private subnets to access the internet
# - Appropriate route tables and associations
# ---------------------------------------------------------------------------------------------------------------------

# Create VPC
# This is the main Virtual Private Cloud that will contain all our resources
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"  # Defines the IP address range for the VPC
  enable_dns_support   = true           # Enables DNS support within the VPC
  enable_dns_hostnames = true           # Enables DNS hostnames for EC2 instances

  tags = {
    Name = var.vpc_name
  }
}



/*# CREATE KAFKA SUBNET
CREATE KAFKA SUBNET
CREATE KAFKA SUBNET
CREATE KAFKA SUBNET
CREATE KAFKA SUBNET
 */


# Create Public Subnet
# This subnet will host resources that need to be accessible from the internet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id  # Associates this subnet with our VPC
  cidr_block              = "10.0.1.0/24"        # Defines the IP address range for this subnet
  map_public_ip_on_launch = true                 # Automatically assigns public IPs to resources launched in this subnet

  tags = {
    Name = var.public_subnet_name
  }
}

# Create Private Subnet for AI Workloads
# This subnet will host AI/ML resources that need internet access via NAT but shouldn't be directly accessible
resource "aws_subnet" "private_subnet_ai" {
  vpc_id     = aws_vpc.main_vpc.id  # Associates this subnet with our VPC
  cidr_block = "10.0.2.0/24"        # Defines the IP address range for this subnet

  tags = {
    Name = var.private_subnet_ai_name
  }
}

# Create Private Subnet for Database
# This subnet will host database resources that should be isolated from direct internet access
resource "aws_subnet" "private_subnet_db" {
  vpc_id     = aws_vpc.main_vpc.id  # Associates this subnet with our VPC
  cidr_block = "10.0.3.0/24"        # Defines the IP address range for this subnet

  tags = {
    Name = var.private_subnet_db_name
  }
}

resource "aws_subnet" "private_subnet_kafka" {
  vpc_id     = aws_vpc.main_vpc.id  # Associates this subnet with our VPC
  cidr_block = "10.0.4.0/24"        # Defines the IP address range for this subnet

  tags = {
    Name = var.private_subnet_kafka_name
  }
}

resource "aws_subnet" "private_subnet_backendApi" {
  vpc_id     = aws_vpc.main_vpc.id  # Associates this subnet with our VPC
  cidr_block = "10.0.5.0/24"        # Defines the IP address range for this subnet

  tags = {
    Name = var.private_subnet_backendApi_name
  }
}

# Create Internet Gateway
# This allows resources in the public subnet to access the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id  # Attaches the IGW to our VPC

  tags = {
    Name = var.igw_name
  }
}

# Create Public Route Table
# This route table will direct traffic from the public subnet to the internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id  # Associates this route table with our VPC

  route {
    cidr_block = "0.0.0.0/0"                    # All traffic not destined for the VPC
    gateway_id = aws_internet_gateway.igw.id    # Will be routed through the internet gateway
  }

  tags = {
    Name = var.public_route_table_name
  }
}

# Associate Public Subnet with Public Route Table
# This links the public subnet to the public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id     # The subnet to associate
  route_table_id = aws_route_table.public_rt.id    # The route table to associate with
}

# Allocate an Elastic IP for the NAT Gateway
# This provides a static public IP address for the NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = {
    Name = var.nat_eip_name
  }
}

# Create NAT Gateway
# This allows resources in private subnets to access the internet while remaining private
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id             # Associates the Elastic IP with this NAT Gateway
  subnet_id     = aws_subnet.public_subnet.id    # Places the NAT Gateway in the public subnet

  tags = {
    Name = var.nat_gw_name
  }
}

# Create Private Route Table
# This route table will direct traffic from private subnets to the NAT Gateway for internet access
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id  # Associates this route table with our VPC

  route {
    cidr_block     = "0.0.0.0/0"                # All traffic not destined for the VPC
    nat_gateway_id = aws_nat_gateway.nat_gw.id  # Will be routed through the NAT Gateway
  }

  tags = {
    Name = var.private_route_table_name
  }
}

# Associate Private Route Table to Private Subnets
# This links the AI private subnet to the private route table
resource "aws_route_table_association" "private_subnet_ai_assoc" {
  subnet_id      = aws_subnet.private_subnet_ai.id  # The AI subnet to associate
  route_table_id = aws_route_table.private_rt.id    # The route table to associate with
}

# Associate Private Route Table to DB Private Subnet
# This links the DB private subnet to the private route table
resource "aws_route_table_association" "private_subnet_db_assoc" {
  subnet_id = aws_subnet.private_subnet_db.id
  route_table_id = aws_route_table.private_rt.id 
}

# Associate Private Route Table to Kafka Private Subnet
resource "aws_route_table_association" "private_subnet_kafka_assoc" {
  # This links the Kafka private subnet to the private route table
  subnet_id      = aws_subnet.private_subnet_kafka.id  # The Kafka subnet to associate
  route_table_id = aws_route_table.private_rt.id       # The route table to associate with
}

resource "aws_route_table_association" "private_subnet_backendApi_assoc" {
  # This links the Backend API private subnet to the private route table
  subnet_id      = aws_subnet.private_subnet_backendApi.id  # The Backend API subnet to associate
  route_table_id = aws_route_table.private_rt.id             # The route table to associate with
}