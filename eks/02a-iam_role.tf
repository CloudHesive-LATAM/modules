# ----------------- ROLE 1: EKS MASTER NODES ----------------- #
# Here, using data, you will create the EKS master role and it's policy document
# using the defined parameters (variable.tf file :D)

# [STEP 1] - Create the base policy document (based on variables.tf)
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document

# Generates an IAM policy document in JSON format for use with resources 
# that expect policy documents such as aws_iam_policy.
data "aws_iam_policy_document" "master_assume_role_policy_document" {
  # create the "json" policy starting with statement 
  #(statement objects >=1)
  statement {
    effect  = var.eks_master_IAM_policy_parameters["effect"]  # Allow
    actions = var.eks_master_IAM_policy_parameters["actions"] # sts assume role

    principals {
      type        = var.eks_master_IAM_policy_parameters["type"]        # Service
      identifiers = var.eks_master_IAM_policy_parameters["identifiers"] # who can assume it

    }

  }
}

# [STEP 2] - Create the role and name it / Add the STS policy
resource "aws_iam_role" "eks_master_role" {
  depends_on = [
    data.aws_iam_policy_document.master_assume_role_policy_document
  ]
  name = "master-role-${var.eks_master_IAM_policy_parameters["name"]}-${var.eks_environment}-${var.eks_application_definition}"
  # Like a trick, attach user defined policy first
  assume_role_policy = data.aws_iam_policy_document.master_assume_role_policy_document.json

}

# [STEP 3] - Attach "AWS managed" policies to the role 
resource "aws_iam_role_policy_attachment" "eks_master_policies_to_be_attached" {
  # Policies are defined as a list! it is needed to be converted to a SET.
  # Once defined, we have to iterate over it 
  depends_on = [
    aws_iam_role.eks_master_role
  ]
  # Iterating with For_Each
  for_each   = toset(var.eks_master_IAM_policy_parameters["policies"])
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_master_role.name

}

# END ----------------- ROLE 1: EKS MASTER NODES ----------------- #

# ----------------- ROLE 2: EKS WORKER NODES ----------------- #

# [STEP 1] - Create document policy (based on variables)
data "aws_iam_policy_document" "worker_assume_role_policy_document" {
  statement {
    effect  = var.eks_worker_IAM_policy_parameters["effect"]
    actions = var.eks_worker_IAM_policy_parameters["actions"]
    principals {
      type        = var.eks_worker_IAM_policy_parameters["type"]
      identifiers = var.eks_worker_IAM_policy_parameters["identifiers"]
    }
  }
}

# [STEP 2] - Create role and name it
resource "aws_iam_role" "eks_worker_role" {
  depends_on = [
    data.aws_iam_policy_document.worker_assume_role_policy_document
  ]
  name               = "${var.eks_worker_IAM_policy_parameters["name"]}-${var.eks_environment}-${var.eks_application_definition}"
  assume_role_policy = data.aws_iam_policy_document.worker_assume_role_policy_document.json
}

# [STEP 3] - Attach inline policies
resource "aws_iam_role_policy_attachment" "eks_worker_policies_to_be_attached" {
  for_each   = toset(var.eks_worker_IAM_policy_parameters["policies"])
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.eks_worker_role.name
}

# END ----------------- ROLE 2: EKS WORKER NODES ----------------- #