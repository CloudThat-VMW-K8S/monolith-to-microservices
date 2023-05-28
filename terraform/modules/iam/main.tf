resource "aws_iam_role" "k8sec2" {
  name               = var.k8sec2_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "k8sec2" {
  name        = var.k8sec2_policy_name
  policy      = file(var.k8sec2_iam_policy_file)
  description = "Single Node Cluster on EC2 using k8s"
}

resource "aws_iam_role_policy_attachment" "k8sec2policyroleattachment" {
  role       = aws_iam_role.k8sec2.name
  policy_arn = aws_iam_policy.k8sec2.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.instance_profile_name

  role = aws_iam_role.k8sec2.name
}