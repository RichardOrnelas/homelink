## VPC Settings from the Infrastucture Repo ###
data "aws_vpc" "primary" {
  tags = {
    Name = "Chainlink"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.primary.id]
  }

  tags = {
    Network = "public"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.primary.id]
  }

  tags = {
    Network = "private"
  }
}

### Security Groups ###
resource "aws_security_group" "alb_public" {
  name        = "alb-public-${terraform.workspace}"
  description = "Allow public internet traffic to load balancer"
  vpc_id      = data.aws_vpc.primary.id
}

resource "aws_security_group_rule" "alb_public_80_platform" {
  security_group_id = aws_security_group.alb_public.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.ip_whitelist
  description       = "Allow public network traffic over HTTP"
}

resource "aws_security_group_rule" "alb_public_443_platform" {
  security_group_id = aws_security_group.alb_public.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.ip_whitelist
  description       = "Allow public network traffic over HTTP"
}

resource "aws_security_group" "ecs" {
  name        = "ecs-access-${terraform.workspace}"
  description = "ecs and ec2 sg"
  vpc_id      = data.aws_vpc.primary.id
}

resource "aws_security_group_rule" "ecs_self" {
  security_group_id = aws_security_group.ecs.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  description       = "Allow private network traffic from itself over all ports"
}

resource "aws_security_group_rule" "ecs_sg_https" {

  security_group_id        = aws_security_group.ecs.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_public.id
  description              = "Allow private network traffic from Acorns security groups over HTTPS"
}

resource "aws_security_group_rule" "ecs_sg_http" {

  security_group_id        = aws_security_group.ecs.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_public.id
  description              = "Allow private network traffic from Acorns security groups over HTTP"
}

resource "aws_security_group" "rds" {
  name        = "rds-access-${terraform.workspace}"
  description = "ECS RDS Instance Access"
  vpc_id      = data.aws_vpc.primary.id
}

resource "aws_security_group_rule" "rds_postgres_ecs" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow postgres traffic from ECS cluster"
}

locals {
  security_groups = [
    aws_security_group.alb_public.id,
    aws_security_group.ecs.id,
    aws_security_group.rds.id
  ]
}

resource "aws_security_group_rule" "egress" {
  count = length(local.security_groups)

  security_group_id = element(local.security_groups, count.index)
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outbound internet"
}

### RDS ###
resource "aws_db_subnet_group" "ecs" {
  name        = "db-subnets-${terraform.workspace}"
  subnet_ids  = data.aws_subnets.private.ids
  description = "RDS Subnets - ${terraform.workspace}"
}

resource "random_password" "rds_password" {
  length  = 32
  special = false
  lower   = true
  numeric = true
  upper   = true
  keepers = {
    # If you want to rotate the password, then just change this value
    "last-updated" = "2023-06-03"
  }
}

resource "aws_db_instance" "primary" {

  allocated_storage            = 20
  storage_type                 = "gp2"
  engine                       = "postgres"
  engine_version               = var.db_postgres_version
  instance_class               = var.db_instance_class
  db_name                      = var.project
  identifier                   = "${var.project}-${terraform.workspace}"
  username                     = var.project
  password                     = random_password.rds_password.result
  port                         = 5432
  parameter_group_name         = var.db_parameter_group
  vpc_security_group_ids       = [aws_security_group.rds.id]
  db_subnet_group_name         = aws_db_subnet_group.ecs.name
  backup_retention_period      = 7
  auto_minor_version_upgrade   = true
  apply_immediately            = true
  copy_tags_to_snapshot        = true
  skip_final_snapshot          = terraform.workspace == "production" ? false : true
  final_snapshot_identifier    = "${var.project}-${terraform.workspace}-final"
  storage_encrypted            = true
  multi_az                     = terraform.workspace == "production" ? true : false
  performance_insights_enabled = false
  deletion_protection          = terraform.workspace == "production" ? true : false
  # performance_insights_retention_period = terraform.workspace == "production" ? 7 : 0
}

### CLOUDWATCH Logs ###
resource "aws_cloudwatch_log_group" "web" {
  name              = "${var.project}/${terraform.workspace}/web"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "${var.project}/${terraform.workspace}/worker"
  retention_in_days = 7
}

### SSM ###
resource "aws_ssm_parameter" "DATABASE_URL" {

  name        = "/${var.project}/${terraform.workspace}/DATABASE_URL"
  description = "Database URL for the Chainlink application"
  type        = "SecureString"
  value       = format("postgres://%s:%s@%s/%s", aws_db_instance.primary.username, random_password.rds_password.result, aws_db_instance.primary.endpoint, aws_db_instance.primary.name)

}

resource "aws_ssm_parameter" "APP_BUCKET" {

  name        = "/${var.project}/${terraform.workspace}/APP_BUCKET"
  description = "Application Bucket for the Chainlink Application"
  type        = "SecureString"
  value       = aws_s3_bucket.bucket.id

}

### Application Load Balancer ###
data "aws_acm_certificate" "primary" {
  domain   = "chainlink.deepseas.dev"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "primary" {
  name         = "deepseas.dev"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = join(".", compact([terraform.workspace == "production" ? "" : terraform.workspace, "chainlink.deepseas.dev"]))
  type    = "A"

  alias {
    name                   = aws_alb.web.dns_name
    zone_id                = aws_alb.web.zone_id
    evaluate_target_health = false
  }
}

resource "aws_alb" "web" {
  name            = "${var.project}-${terraform.workspace}"
  internal        = false
  security_groups = [aws_security_group.alb_public.id]
  subnets         = data.aws_subnets.public.ids
}

resource "aws_alb_target_group" "http" {
  name        = "${var.project}-${terraform.workspace}-http"
  port        = "8080"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.primary.id

  health_check {
    healthy_threshold   = 3
    path                = "/healthcheck"
    timeout             = 5
    unhealthy_threshold = 2
    interval            = 10
    matcher             = "200"
  }

  deregistration_delay = 30
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.web.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.primary.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_alb_target_group.http.arn
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      default_action
    ]
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_alb_target_group.http.arn
    type             = "forward" #TODO: Switch this to redirect to HTTPS
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      default_action
    ]
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tf-${var.project}-${terraform.workspace}"
}

### SQS ###
variable "queues" {
  type = list(string)

  default = [
    "main",
    "high"
  ]
}

resource "aws_sqs_queue" "queue" {
  count                     = length(var.queues)
  name                      = "${var.project}_${terraform.workspace}_${element(var.queues, count.index)}"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 605000
  receive_wait_time_seconds = 20
  sqs_managed_sse_enabled   = true
  redrive_policy            = "{\"deadLetterTargetArn\":\"${element(aws_sqs_queue.queue_dead.*.arn, count.index)}\",\"maxReceiveCount\":2}"

}

resource "aws_sqs_queue" "queue_dead" {
  count                     = length(var.queues)
  name                      = "${var.project}_${terraform.workspace}_${element(var.queues, count.index)}_dead"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 20
  sqs_managed_sse_enabled   = true


}

resource "aws_sqs_queue_policy" "queue" {
  lifecycle {
    ignore_changes = [
      policy
    ]
  }

  count     = length(var.queues)
  queue_url = element(aws_sqs_queue.queue.*.id, count.index)

  policy = element(data.aws_iam_policy_document.queue_policy.*.json, count.index)
}

data "aws_iam_policy_document" "queue_policy" {
  count = length(var.queues)
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [element(aws_sqs_queue.queue.*.id, count.index)]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [element(aws_sqs_queue.queue.*.arn, count.index)]
    }
  }
}


### ECS ###
resource "aws_ecr_repository" "homelink" {
  count                = terraform.workspace == "sandbox" ? 1 : 0
  name                 = "homelink"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "primary" {
  name = terraform.workspace
}

resource "aws_ecs_cluster_capacity_providers" "primary" {
  cluster_name = aws_ecs_cluster.primary.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_service" "web" {
  depends_on = [aws_ecs_task_definition.web, aws_iam_role.platform_service]

  name            = "${var.project}-${terraform.workspace}-web"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.web_count
  # iam_role        = aws_iam_role.ecs_service.arn 

  load_balancer {
    target_group_arn = aws_alb_target_group.http.arn
    container_name   = "${var.project}-web"
    container_port   = 8080
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }
}


locals {

  env_vars = {
    RAILS_MAX_THREADS = 8
    PORT              = 8080
    RAILS_ENV         = terraform.workspace == "production" || terraform.workspace == "staging" ? terraform.workspace : "sandbox"
  }

  # Secrets that point to an SSM arn
  secret_vars = {
    DATABASE_URL    = aws_ssm_parameter.DATABASE_URL.arn
    APP_BUCKET_NAME = aws_ssm_parameter.APP_BUCKET.arn
  }

  # Leave these alone
  env_var_array = [for k, v in local.env_vars : {
    name  = k
    value = tostring(v)
  }]
  secret_var_array = [for k, v in local.secret_vars : {
    name      = k
    valueFrom = v
  }]

  base_app_container = {
    image        = var.docker_image
    volumesFrom  = []
    essential    = true
    mountPoints  = []
    portMappings = []
    environment  = local.env_var_array
    secrets      = local.secret_var_array
    startTimeout = 60
    stopTimeout  = 115
  }
}

resource "aws_ecs_task_definition" "web" {
  depends_on = [aws_db_instance.primary, aws_s3_bucket.bucket, aws_sqs_queue.queue, aws_sqs_queue.queue_dead]

  family                   = "homelink-web"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.web_cpu
  memory                   = var.web_mem
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.platform_service.arn

  # container_definitions = templatefile("${path.module}/web_container.tftpl",
  #   {
  #     cpu             = var.web_cpu
  #     mem             = var.web_mem
  #     image           = var.docker_image
  #     environment     = terraform.workspace
  #     rails_env       = terraform.workspace == "production" || terraform.workspace == "staging" ? terraform.workspace : "sandbox"
  #     region          = var.region
  #     database_url    = "postgres://${aws_db_instance.primary.username}:${var.db_password}@${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.name}"
  #     app_bucket_name = aws_s3_bucket.bucket.id
  #     default_queue   = "${var.project}_${terraform.workspace}_main"
  #   }
  # )
  container_definitions = jsonencode([
    merge(local.base_app_container, {
      name = "homelink-web"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.web.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "web"
        }
      }
      portMappings = [
        {
          hostPort      = 8080
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      startTimeout = 60
      stopTimeout  = 115
      command      = ["bundle", "exec", "puma", "-C", "config/puma.rb"]
    })
  ])
}


resource "aws_ecs_service" "worker" {
  depends_on = [aws_ecs_task_definition.worker, aws_iam_role.platform_service]

  name            = "${var.project}-${terraform.workspace}-worker"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_count
  # iam_role        = aws_iam_role.ecs_service.arn 

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }
}

resource "aws_ecs_task_definition" "worker" {
  depends_on = [aws_db_instance.primary, aws_s3_bucket.bucket, aws_sqs_queue.queue, aws_sqs_queue.queue_dead]

  family                   = "homelink-worker"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.worker_cpu
  memory                   = var.worker_mem
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.platform_service.arn

  # container_definitions = templatefile("${path.module}/worker_container.tftpl",
  #   {
  #     cpu             = var.worker_cpu
  #     mem             = var.worker_mem
  #     image           = var.docker_image
  #     environment     = terraform.workspace
  #     rails_env       = terraform.workspace == "production" || terraform.workspace == "staging" ? terraform.workspace : "sandbox"
  #     region          = var.region
  #     database_url    = "postgres://${aws_db_instance.primary.username}:${var.db_password}@${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.name}"
  #     app_bucket_name = aws_s3_bucket.bucket.id
  #     default_queue   = "${var.project}_${terraform.workspace}_main"
  #   }
  # )
  container_definitions = jsonencode([
    merge(local.base_app_container, {
      name = "homelink-worker"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.worker.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "worker"
        }
      }
      startTimeout = 60
      stopTimeout  = 115
      command      = ["bundle", "exec", "shoryuken", "-R", "-C", "config/shoryuken.yml"]
    })
  ])
}
