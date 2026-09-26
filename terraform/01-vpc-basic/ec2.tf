data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "public" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_a.id
  vpc_security_group_ids = [
    aws_security_group.public_ec2.id
  ]

  associate_public_ip_address = true

  key_name = "cloud-study-key"

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "terraform-study-public-ec2"
  }
}

resource "aws_instance" "private" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  subnet_id = aws_subnet.private_a.id
  vpc_security_group_ids = [
    aws_security_group.private_ec2.id
  ]

  associate_public_ip_address = false

  key_name = "cloud-study-key"

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  tags = {
    Name = "terraform-study-private-ec2"
  }
}