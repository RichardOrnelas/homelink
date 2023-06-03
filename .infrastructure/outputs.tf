output "sg_alb_public" {
  value = aws_security_group.alb_public.id
}

output "sg_ecs" {
  value = aws_security_group.ecs.id
}

output "sg_rds" {
  value = aws_security_group.rds.id
}

output "db_endpoint" {
  value = "postgres://${aws_db_instance.primary.username}:password@${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.name}"
}

output "db_arn" {
  value = aws_db_instance.primary.arn
}

output "app_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "target_group_arn" {
  value = aws_alb_target_group.http.arn
}

output "www_fqdn" {
  value = aws_route53_record.www.fqdn
}

output "worker_task_def_arn" {
  value = aws_ecs_task_definition.worker.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.primary.name
}

output "task_subnet" {
  value = data.aws_subnets.private.ids[0]
}
