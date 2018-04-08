/*------------------------*/
/*-- ECS Configurations --*/
/*------------------------*/

/* Task Definition */
data "aws_ecs_task_definition" "dev_webapp" {
  task_definition = "${aws_ecs_task_definition.dev_webapp.family}"
  depends_on = ["aws_ecs_task_definition.dev_webapp"]
}

resource "aws_ecs_task_definition" "dev_webapp" {
  family = "dev-webapp"
  container_definitions = <<DEFINITION
[
  {
    "name": "${var.webapp_container_name}",
    "image": "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.webapp_container_image_name}:latest",
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
resource "aws_ecs_service" "dev_webapp" {
  name = "webapp-service"
  cluster = "${aws_ecs_cluster.dev_beestock.id}"
  task_definition = "${aws_ecs_task_definition.dev_webapp.family}:${max("${aws_ecs_task_definition.dev_webapp.revision}", "${data.aws_ecs_task_definition.dev_webapp.revision}")}"
  iam_role = "${aws_iam_role.service_role.name}"

  desired_count = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  load_balancer {
    elb_name = "${aws_elb.dev_webapp.name}"
    container_port = 8080
    container_name = "${var.webapp_container_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/* ECR Respository */
resource "aws_ecr_repository" "dev_webapp" {
  name = "dev-beestock-webapp"
}


/*------------------------*/
/*-- EC2 Configurations --*/
/*------------------------*/

/* ELB */
resource "aws_elb" "dev_webapp" {
  name = "dev-webapp"
  security_groups = ["${aws_security_group.dev_webapp_elb.id}"]
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

resource "aws_security_group" "dev_webapp_elb" {
  name = "dev-beestock-webapp-elb"
  description = "SG - ELB of Beestock WebApp - Dev Environment"
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
    Name = "dev-beestock-webapp-elb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*----------------------------*/
/*-- Route53 Configurations --*/
/*----------------------------*/

/* Route 53 */
resource "aws_route53_record" "dev_webapp" {
  name = "dev.beesstock.com"
  type = "A"
  zone_id = "Z350L91LBYS5QI"

  alias {
    evaluate_target_health = true
    name = "${aws_elb.dev_webapp.dns_name}"
    zone_id = "${aws_elb.dev_webapp.zone_id}"
  }
}