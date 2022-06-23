resource "aws_security_group" "bastion_host" {
  name        = "bastion_host"
  description = "SSH From  Public IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow Internet Out"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-sg" }, )
}