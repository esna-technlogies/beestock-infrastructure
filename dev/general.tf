/*--------------------------------*/
/*-- General ECS Configurations --*/
/*--------------------------------*/

/* ECS Cluster */
resource "aws_ecs_cluster" "dev_beestock" {
  name = "${var.ecs_cluster_name}"
}


/*-----------------------*/
/*-- EC2 Configurations --*/
/*-----------------------*/

/* Launch Configuration */
resource "aws_launch_configuration" "dev_frontend_beestock" {
  name_prefix = "dev-frontend-beestock"
  image_id = "ami-05b5277d"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.dev_frontend_beestock.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

/* Auto Scalling Group */
resource "aws_autoscaling_group" "dev_frontend_beestock" {
  launch_configuration = "${aws_launch_configuration.dev_frontend_beestock.id}"
  vpc_zone_identifier = [
    "${aws_subnet.dev_beestock_sn0.id}"
  ]

  max_size = 1
  min_size = 1
  health_check_type = "ELB"

  load_balancers = ["${aws_elb.dev_admin_dashboard.id}"]

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "dev-frontend-beestock"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "dev_frontend_beestock" {
  name = "dev-frontend-beestock"
  description = "SG - Frontend Beestock - Dev Environment"
  vpc_id = "${aws_vpc.dev_beestock.id}"

  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8081
    protocol = "tcp"
    to_port = 8081
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "dev-frontend-beestock"
  }

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_availability_zones" "all" {}