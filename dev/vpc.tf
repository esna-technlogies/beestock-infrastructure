resource "aws_vpc" "dev_beestock" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "dev-beestock"
  }
}

resource "aws_internet_gateway" "dev_beestock_ig" {
  vpc_id = "${aws_vpc.dev_beestock.id}"

  tags {
    Name = "dev-beestock-ig"
  }
}


resource "aws_subnet" "dev_beestock_sn0" {
  cidr_block = "10.10.10.0/24"
  vpc_id = "${aws_vpc.dev_beestock.id}"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "dev-beestock-sn1"
  }
}

resource "aws_subnet" "dev_beestock_sn1" {
  cidr_block = "10.10.20.0/24"
  vpc_id = "${aws_vpc.dev_beestock.id}"
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "dev-beestock-sn1"
  }
}

resource "aws_route_table" "dev_beestock_rt0" {
  vpc_id = "${aws_vpc.dev_beestock.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dev_beestock_ig.id}"
  }

  tags {
    Name = "dev-beestock-rt0"
  }
}

resource "aws_route_table_association" "dev_beestock_rt0_sn0" {
  route_table_id = "${aws_route_table.dev_beestock_rt0.id}"
  subnet_id = "${aws_subnet.dev_beestock_sn0.id}"
}

resource "aws_route_table_association" "dev_beestock_rt0_sn1" {
  route_table_id = "${aws_route_table.dev_beestock_rt0.id}"
  subnet_id = "${aws_subnet.dev_beestock_sn1.id}"
}

resource "aws_security_group" "dev_beestock_default" {
  name = "dev-beestock-default"
  description = "Default SG - Beestock - Dev Environment"
  vpc_id = "${aws_vpc.dev_beestock.id}"

  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "dev-beestock-default"
  }

  lifecycle {
    create_before_destroy = true
  }
}
