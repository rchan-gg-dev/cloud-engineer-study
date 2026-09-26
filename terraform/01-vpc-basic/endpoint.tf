resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-2.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id
  ]

  security_group_ids = [
    aws_security_group.ssm_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "terraform-study-ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-2.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id
  ]

  security_group_ids = [
    aws_security_group.ssm_endpoint.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "terraform-study-ssmmessages-endpoint"
  }
}