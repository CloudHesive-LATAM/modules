#Grabbing latest Linux 2 AMI
data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#EC2 IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ssm"
  role = aws_iam_role.ec2_policy_role.name
}

# EC2 Deploy
resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ami.linux2.id
  instance_type               = var.instance_type["type1"]
  subnet_id                   = var.public_subnets[0]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

eksctl version

sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
kubectl version --short --client

curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short
  EOF


  tags                        = merge(var.project-tags, { Name = "${var.resource-name-tag}-EC2" }, )

  root_block_device {
    volume_size           = 120
    volume_type           = "gp3"
    delete_on_termination = true
    tags                  = merge(var.project-tags, { Name = "${var.resource-name-tag}-EBS" }, )
  }
}

output "ssh_command" {
  value = "sudo ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.bastion-host.public_ip}"
}