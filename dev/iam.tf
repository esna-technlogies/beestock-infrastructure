/* IAM Role/Policy/Profile */
resource "aws_iam_role" "instance_role" {
  name = "instance-role"
  path = "/"
  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  ROLE
}

resource "aws_iam_role" "service_role" {
  name = "service-role"
  path = "/"
  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  ROLE
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = "${aws_iam_role.instance_role.name}"
}

resource "aws_iam_instance_profile" "service_profile" {
  name = "service-profile"
  role = "${aws_iam_role.service_role.name}"
}

resource "aws_iam_role_policy_attachment" "instance_policy_attachment" {
  role = "${aws_iam_role.instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "service_policy_attachment" {
  role = "${aws_iam_role.service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

