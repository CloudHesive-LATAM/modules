/* EC2 IAM Role:Allow EC2 to be managed by SSM Session Manager */

# EC2 IAM Policy Document Name of role AmazonSSMManagedInstanceCore
data "aws_iam_policy_document" "ec2_policy_source" {
  statement {
    sid    = "AllowSSMSessionManager"
    effect = "Allow"
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    resources = ["*"]
  }
}

# EC2 IAM Role Policy Document
data "aws_iam_policy_document" "ec2_role_source" {
  statement {
    sid    = "EC2AssumeRole"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ssm.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

# EC2 IAM Policy
resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Get AppConfig Configurations"
  policy      = data.aws_iam_policy_document.ec2_policy_source.json
  tags        = merge(var.project-tags, { Name = "${var.resource-name-tag}-ec2-policy" }, )
}

# EC2 IAM Role
resource "aws_iam_role" "ec2_policy_role" {
  name               = "EC2PolicyRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_role_source.json
  tags               = merge(var.project-tags, { Name = "${var.resource-name-tag}-ec2-role" }, )
}

# Attach EC2 Role and EC2 Policy
resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_policy_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}