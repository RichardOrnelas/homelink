# ECS Execution
resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project}-${terraform.workspace}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_grant.json
  description        = "${var.project} ECS Task Execution Role"
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name   = "${var.project}-${terraform.workspace}-ecs-execution-policy"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution_policy.json
}

data "aws_iam_policy_document" "ecs_execution_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:Create*",
      "logs:Put*"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:GetParameters",
      # "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "ecs_execution_grant" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

# ECS Service Role
resource "aws_iam_role" "ecs_service" {
  name               = "${var.project}-${terraform.workspace}-ecs-service"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_grant.json

  description = "${var.project} ECS Service Role"
}

resource "aws_iam_role_policy" "ecs_service" {
  name   = "${var.project}-${terraform.workspace}-ecs-service-policy"
  role   = aws_iam_role.ecs_service.id
  policy = data.aws_iam_policy_document.ecs_service_policy.json
}

data "aws_iam_policy_document" "ecs_service_grant" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_service_policy" {

  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:RegisterTargets"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECSTaskManagement"
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteNetworkInterfacePermission",
      "ec2:Describe*",
      "ec2:DetachNetworkInterface",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "route53:ChangeResourceRecordSets",
      "route53:CreateHealthCheck",
      "route53:DeleteHealthCheck",
      "route53:Get*",
      "route53:List*",
      "route53:UpdateHealthCheck",
      "servicediscovery:DeregisterInstance",
      "servicediscovery:Get*",
      "servicediscovery:List*",
      "servicediscovery:RegisterInstance",
      "servicediscovery:UpdateInstanceCustomHealthStatus"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ECSTagging"
    actions = [
      "ec2:CreateTags",
    ]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]
  }

}


### Task Role ###

resource "aws_iam_role" "platform_service" {
  name               = "tf-${var.project}-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.grant.json
}

resource "aws_iam_role_policy" "platform_service_policy" {
  name   = "${var.project}-${terraform.workspace}-service-policy"
  role   = aws_iam_role.platform_service.id
  policy = data.aws_iam_policy_document.platform_service.json
}

data "aws_iam_policy_document" "platform_service" {

  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:SendMessageBatch",
      "sqs:ListQueues"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecs:*",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:Describe*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "sns:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "grant" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

