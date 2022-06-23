data "aws_availability_zones" "aws" {
  state = "available"
}

#-------------------------------------
# VPC Definition
#------------------------------------
resource "aws_vpc" "poc_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-vpc" }, )
}

#-------------------------------------
# SUBNET Definition
#------------------------------------
# Public Subnet 
resource "aws_subnet" "poc_public" {
  for_each          = { for i, v in var.PublicSubnet-List : i => v } #por cada valor de objeto en lista de variables genera un nuevo objeto.
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.aws.names[each.value.az]

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-${each.value.name}" }, )
}

# private Subnet 
resource "aws_subnet" "poc_private" {
  for_each          = { for i, v in var.PrivateSubnet-List : i => v }
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.aws.names[each.value.az]

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-${each.value.name}" }, )
}

#---------------------------
#transit gateway attachment
#---------------------------
# resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
#   transit_gateway_id = var.tgw_id
#   vpc_id             = aws_vpc.poc_vpc.id
#   subnet_ids         = [aws_subnet.poc_private[0].id,aws_subnet.poc_private[1].id]
# }
#----------------------
# Internet Gateway vpc
#----------------------
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.poc_vpc.id

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-ig-" }, )
}

#-------------------------------------
# Route table Definition
#------------------------------------
# Public Route Table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.poc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-rtpub" }, )
}

# Private Route Table 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.poc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    #transit_gateway_id = var.tgw_id
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-rtpriv" }, )
}

# Public Subnets Association 
resource "aws_route_table_association" "public" {
  count          = length(var.PublicSubnet-List)
  subnet_id      = aws_subnet.poc_public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Subnets Association
resource "aws_route_table_association" "private" {
  count          = length(var.PrivateSubnet-List)
  subnet_id      = aws_subnet.poc_private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}


