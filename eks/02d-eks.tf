
# EKS Cluster Definition:
resource "aws_eks_cluster" "eks-cluster" {
  
  name                      = "${var.eks_master_IAM_policy_parameters["name"]}-${var.eks_environment}-${var.eks_application_definition}"
  role_arn                  = aws_iam_role.eks_master_role.arn
  enabled_cluster_log_types = var.cluster_log_type
  version                   = var.cluster_version["latest_version"]
  tags                      = merge(var.project-tags, { Name = "${var.resource-name-tag}-cluster" }, )

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true
    subnet_ids              = var.private_subnets
    security_group_ids      = [aws_security_group.EKS_SG.id]
  }
  
  # I must wait until role has been created
  # and policies has been attached.
  depends_on = [
    aws_iam_role.eks_master_role,
    aws_iam_role_policy_attachment.eks_master_policies_to_be_attached
  ]
}

# Node Group 2
resource "aws_eks_node_group" "eks-ng-2" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-ng-2"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = var.private_subnets

  # instance_types  = [var.instance_type["type1"]]
  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-ng-1" }, )

  scaling_config {
    desired_size = 1
    max_size     = 50
    min_size     = 1
  }

  launch_template {
    name    = data.aws_launch_template.POC.name
    version = data.aws_launch_template.POC.latest_version
  }

  depends_on = [
    aws_iam_role.eks_worker_role,
    aws_iam_role_policy_attachment.eks_worker_policies_to_be_attached
  ]
} 

# Node Group 3
resource "aws_eks_node_group" "eks-ng-3" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-ng-3"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = var.private_subnets

  # instance_types  = [var.instance_type["type1"]]
  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-ng-3" }, )

  scaling_config {
    desired_size = 1
    max_size     = 50
    min_size     = 1
  }

  launch_template {
    name    = data.aws_launch_template.POC.name
    version = data.aws_launch_template.POC.latest_version
  }
  #   remote_access {
  #     ec2_ssh_key = var.eks_nodes_key
  #     source_security_group_ids = []
  #   }

  depends_on = [
    aws_iam_role.eks_worker_role,
    aws_iam_role_policy_attachment.eks_worker_policies_to_be_attached
  ]
}
/*

# /ADDON Groups Definition: 
# #coreDNS
# resource "aws_eks_addon" "coreDNS" {
#   cluster_name  = aws_eks_cluster.eks-cluster.name
#   addon_name    = "coredns"
#   addon_version = "v1.8.4-eksbuild.1"
#   resolve_conflicts        = "OVERWRITE"
# }

 /* # kube-proxy
resource "aws_eks_addon" "kube-proxy" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.21.2-eksbuild.2"
  service_account_role_arn = aws_iam_role.Cluster-nodes-role-eks.arn
}

# vpc-cni
resource "aws_eks_addon" "vpc-cni" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  addon_name    = "vpc-cni"
  addon_version = "v1.10.1-eksbuild.1"
} */

