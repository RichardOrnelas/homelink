variable "project" {
  type        = string
  description = "Name of the project"
  default     = "homelink"
}

variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "us-east-1"
}

variable "ip_whitelist" {
  type        = list(any)
  description = "IP Whitelist for non-production"
  default     = ["0.0.0.0/0"]
}

variable "db_postgres_version" {
  type        = string
  description = "Postgres database version"
  default     = "15.3"
}

variable "db_parameter_group" {
  type        = string
  description = "Postgres database parameter group name"
  default     = "default.postgres15"
}

variable "db_instance_class" {
  type        = string
  description = "Size and Class for the RDS Postgres instance"
  default     = "db.t3.micro"
}

variable "web_cpu" {
  type        = number
  description = "CPU units for web task"
  default     = 512
}

variable "web_mem" {
  type        = number
  description = "Mem units for web task"
  default     = 1024
}

variable "web_count" {
  type        = number
  description = "# of tasks running for web service"
  default     = 2
}

variable "worker_cpu" {
  type        = number
  description = "CPU units for worker task"
  default     = 512
}

variable "worker_mem" {
  type        = number
  description = "Mem units for worker task"
  default     = 1024
}

variable "worker_count" {
  type        = number
  description = "# of tasks running for worker service"
  default     = 2
}

variable "docker_image" {
  type        = string
  description = "Docker image to deploy"
  default     = "webdestroya/http-placeholder:latest"
}
