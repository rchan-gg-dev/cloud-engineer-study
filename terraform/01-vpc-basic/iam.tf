data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name = "terraform-study-ec2-ssm-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "terraform-study-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "terraform-study-ec2-ssm-profile"
  role = aws_iam_role.ssm.name
}