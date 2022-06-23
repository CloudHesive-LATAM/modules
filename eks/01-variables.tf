## EKS specific resources
variable "eks_environment" {
  type    = string
  default = "development"
}

variable "eks_application_definition" {
  type    = string
  default = "main"

}

variable "private_subnets" {
  type        = list(string)
  description = "Private Subnets"
  default     = []
}

variable "sg_ports_list" {
  type = list(object({
    port     = number
    protocol = string
    cidr     = list(string)

  }))
  default = [
    {
      port     = 31103
      protocol = "tcp"
      cidr     = ["0.0.0.0/0"]
    },
    {
      port     = 443
      protocol = "tcp"
      cidr     = ["10.20.227.48/32"]
    },
    {
      port     = 30128
      protocol = "tcp"
      cidr     = ["0.0.0.0/0"]
    },
    {
      port     = 30614
      protocol = "tcp"
      cidr     = ["0.0.0.0/0"]
    },
    {
      port     = 30301
      protocol = "tcp"
      cidr     = ["10.180.0.0/24", "10.180.1.0/24", "10.180.2.0/24"]
    },
  ]
}
# [STEP 1] - Define IAM Policy Parameters (this is gonna be used in Policy-Roles EKS)
variable "eks_master_IAM_policy_parameters" {
  # Default value
  default = {
    name        = "EKS-Cluster-Master"
    effect      = "Allow"
    actions     = ["sts:AssumeRole"]
    type        = "Service"
    identifiers = ["eks.amazonaws.com"]                                # <- STS Policy (document policy)
    policies    = ["AmazonEKSClusterPolicy", "AmazonEKSServicePolicy"] # <- AWS Managed Policies 

  }

  # Or wait for user defined data
  type = object({
    name        = string
    effect      = string
    actions     = list(string)
    type        = string
    identifiers = list(string)
    policies    = list(string)

  })
}

variable "eks_worker_IAM_policy_parameters" {
  default = {
    name        = "EKS-Cluster-Worker"
    effect      = "Allow"
    actions     = ["sts:AssumeRole"]
    type        = "Service"
    identifiers = ["ec2.amazonaws.com"]
    policies    = ["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly", "CloudWatchFullAccess"]
  }
  type = object({
    name        = string
    effect      = string
    actions     = list(string)
    type        = string
    identifiers = list(string)
    policies    = list(string)
  })
}

##AWS Region
#Use: var.aws_region["source"]
variable "aws_region" {
  type = map(string)
  default = {
    "source"      = "us-east-1",
    "destination" = "us-west-2"
  }
}

# TGW ID 
variable "tgw_id" {
  type    = string
  default = "tgw-048609c6fa8097f5c"
}

variable "vpc_id" {
  type    = string
  default = ""
}
# VPC  cidr block
variable "vpc_cidr" {
  type    = string
  default = "10.48.0.0/16"
}


/* EKS Cluster Node EC2 Instance type */
#Use: var.instance_type["source"]
variable "instance_type" {
  type = map(string)
  default = {
    "dev_env"                = "t2.small",
    "qa_env"                 = "t3.small",
    "prod_mem_optimized_env" = "m5.large",
    "prod_cpu_optimized_env" = "c5.large",
  }
}

/* SSH Key-Pair */

#Bastion Key
variable "bastion_key" {
  type    = string
  default = "Bastion-Key"
}

#EKS Nodes Key
variable "eks_nodes_key" {
  type    = string
  default = "EKS-Nodes-Key"
}

/* EKS Variable */

variable "cluster_name" {
  default = "demo-eks-cluster"
}

#Use: instance_type = var.cluster_version["version1"]
variable "cluster_version" {
  description = "Kubernetes version supported by EKS. Ref: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"
  type        = map(string)
  default = {
    "latest_version"   = "1.21",
    "lts_version"      = "1.20",
    "previous_version" = "1.19.2",
    "oldest_supported" = "1.18.8"
  }
}


variable "cluster_log_type" {
  description = "Amazon EKS control plane logging Ref: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html"
  type        = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "scheduler",
    "controllerManager"
  ]
}

variable "cluster_log_retention_days" {
  default = "90"
}


### Tags Variables ###
#Use: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-place-holder" }, )
variable "project-tags" {
  type = map(string)
  default = {
    service     = "S3Replication",
    environment = "POC"
    owner       = "example@mail.com"
  }
}

variable "resource-name-tag" {
  type    = string
  default = "S3Replication"
}