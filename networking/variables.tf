##AWS Region
#Use: var.aws_region["source"]
variable "aws_region" {
  type = map(string)
  default = {
    "virginia" = "us-east-1",
    "oregon"   = "us-west-2"
  }
}

# TGW ID 
variable "tgw_id" {
  type    = string
  default = "ID_TGW"
}


# VPC  cidr block
variable "vpc_cidr" {
  type    = string
  default = "10.48.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets"
  default     = []
}

#Use for subnet: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-${each.value.name}" }, )
variable "PublicSubnet-List" {
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))
  default = [
    {
      name    = "Public-0"
      az      = 0
      newbits = 8
      netnum  = 10
    },
    {
      name    = "Public-2"
      az      = 1
      newbits = 8
      netnum  = 12
    },
  ]
}

variable "PrivateSubnet-List" {
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))
  default = [
    {
      name    = "Private-0"
      az      = 0
      newbits = 8
      netnum  = 20
    },
    {
      name    = "Private-1"
      az      = 1
      newbits = 8
      netnum  = 21
    },
  ]
}

variable "PrivateSubnetdb-List" {
  type = list(object({
    name    = string
    az      = number
    newbits = number
    netnum  = number
  }))
  default = [
    {
      name    = "Privatebd-0"
      az      = 0
      newbits = 8
      netnum  = 15
    },
    {
      name    = "Privatebd-1"
      az      = 1
      newbits = 8
      netnum  = 16
    },
  ]
}

### Tags Variables ###
#Use: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-place-holder" }, )
variable "project-tags" {
  type = map(string)
  default = {
    service     = "Ec2",
    app = "POC",
    app2 = "POC2"
  }
}

variable "resource-name-tag" {
  type    = string
  default = "Ec2Poc"
}

