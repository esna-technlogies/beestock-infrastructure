/*-----------------------*/
/*-- ECS Configuration --*/
/*-----------------------*/

/* Task Definition */
data "aws_ecs_task_definition" "dev_admin_dashboard" {
  task_definition = "${aws_ecs_task_definition.dev_admin_dashboard.family}"
  depends_on = ["aws_ecs_task_definition.dev_admin_dashboard"]
}

resource "aws_ecs_task_definition" "dev_admin_dashboard" {
  family = "dev-admin-dashboard"
  container_definitions = <<DEFINITION
[
  {
    "name": "${var.admin_dashboard_container_name}",
    "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.admin_dashboard_container_image_name}:latest",
    "cpu": 10,
    "memory": 300,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
  DEFINITION

  lifecycle {
    create_before_destroy = true
  }
}

/* Service */
resource "aws_ecs_service" "dev_admin_dashboard" {
  name = "admin-dashboard-service"
  cluster = "${aws_ecs_cluster.dev_beestock.id}"
  task_definition = "${aws_ecs_task_definition.dev_admin_dashboard.family}:${max("${aws_ecs_task_definition.dev_admin_dashboard.revision}", "${data.aws_ecs_task_definition.dev_admin_dashboard.revision}")}"
  iam_role = "${aws_iam_role.service_role.name}"

  desired_count = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  load_balancer {
    elb_name = "${aws_elb.dev_admin_dashboard.name}"
    container_port = 8080
    container_name = "${var.admin_dashboard_container_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/* ECR Respository */
resource "aws_ecr_repository" "dev_admin_dashboard" {
  name = "dev-beestock-admin-dashboard"
}

/*-----------------------*/
/*-- EC2 Configuration --*/
/*-----------------------*/

/* Launch Configuration */
resource "aws_launch_configuration" "dev_admin_dashboard" {
  name_prefix = "dev-admin-dashboard-"
  image_id = "ami-1b90a67e"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.dev_admin_dashboard.id}"]
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
resource "aws_autoscaling_group" "dev_admin_dashboard" {
  launch_configuration = "${aws_launch_configuration.dev_admin_dashboard.id}"
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
    value = "frontend-admin-dashboard"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/* ELB */
resource "aws_elb" "dev_admin_dashboard" {
  name = "dev-admin-dashboard"
  security_groups = ["${aws_security_group.dev_admin_dashboard_elb.id}"]
  subnets = [
    "${aws_subnet.dev_beestock_sn0.id}"
  ]

  "listener" {
    instance_port = 8080
    instance_protocol = "HTTP"
    lb_port = 80
    lb_protocol = "HTTP"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/"
    interval = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "dev_admin_dashboard_elb" {
  name = "dev-beestock-admin-dashboard-elb"
  description = "SG - ELB of Beestock Admin Dashboard - Dev Environment"
  vpc_id = "${aws_vpc.dev_beestock.id}"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "dev-beestock-admin-dashboard-elb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "dev_admin_dashboard" {
  name = "dev-beestock-admin-dashboard"
  description = "SG - Beestock Admin Dashboard - Dev Environment"
  vpc_id = "${aws_vpc.dev_beestock.id}"

  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "dev-beestock-admin-dashboard"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*---------------------------*/
/*-- Route53 Configuration --*/
/*---------------------------*/

/* Route 53 */
resource "aws_route53_record" "dev_admin_dashboard" {
  name = "dev-admin.beesstock.com"
  type = "A"
  zone_id = "Z350L91LBYS5QI"

  alias {
    evaluate_target_health = true
    name = "${aws_elb.dev_admin_dashboard.dns_name}"
    zone_id = "${aws_elb.dev_admin_dashboard.zone_id}"
  }
}