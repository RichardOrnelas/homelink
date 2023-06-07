output "sg_alb_public" {
  value = aws_security_group.alb_public.id
  description = "Security Group assigned to public-facing Application Load Balancers"
}

output "sg_ecs" {
  description = "Security Group assigned to ECS Services"
  value = aws_security_group.ecs.id
}

output "sg_rds" {
  description = "Security Group assigned to RDS instances"
  value = aws_security_group.rds.id
}

output "db_endpoint" {
  description = "RDS instance endpoint URL as postgres URL"
  value = "postgres://${aws_db_instance.primary.username}:password@${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.name}"
}

output "db_arn" {
  description = "RDS PostGres database ARN"
  value = aws_db_instance.primary.arn
}

output "app_bucket" {
  description = "Application AWS S3 bucket name"
  value = aws_s3_bucket.bucket.id
}

output "private_subnets" {
  description = "List of private subnets imported from the VPC"
  value = data.aws_subnets.private.ids
}

output "public_subnets" {
  description = "List of public subnets imported from the VPC"
  value = data.aws_subnets.public.ids
}

output "target_group_arn" {
  description = "ARN for the Target Group belonging to the ECS Web Service"
  value = aws_alb_target_group.http.arn
}

output "www_fqdn" {
  description = "URL for the web application"
  value = aws_route53_record.www.fqdn
}

output "worker_task_def_arn" {
  description = "ARN for the ECS Task Definition for the Worker service used to run database migration tasks"
  value = aws_ecs_task_definition.worker.arn
}

output "ecs_cluster_name" {
  description = "AWS ECS Cluster Name"
  value = aws_ecs_cluster.primary.name
}

output "task_subnet" {
  description = "Private AWS Subnet used for running database migration tasks"
  value = data.aws_subnets.private.ids[0]
}
