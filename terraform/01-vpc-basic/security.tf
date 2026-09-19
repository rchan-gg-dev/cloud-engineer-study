resource "aws_security_group" "public_ec2" {
  name        = "terraform-study-public-ec2-sg"
  description = "Security group for public EC2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "terraform-study-public-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_ec2_http" {
  security_group_id = aws_security_group.public_ec2.id

  description = "Allow HTTP from Internet"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "public_ec2_ssh" {
  security_group_id = aws_security_group.public_ec2.id

  description = "Allow SSH from my IP"
  cidr_ipv4   = var.my_ip_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "public_ec2_all" {
  security_group_id = aws_security_group.public_ec2.id

  description = "Allow all outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
