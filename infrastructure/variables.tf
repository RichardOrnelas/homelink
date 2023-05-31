variable "project" {
  type        = string
  description = "Name of the project"
  default     = "Chainlink"
}

variable "region" {
  type        = string
  description = "AWS Region to deploy resources in"
  default     = "us-east-1"
}

variable "ip_whitelist" {
  type        = list
  description = "IP Whitelist for non-production"
  default     = ["0.0.0.0/0"]
}

variable "db_password" {
  type        = string
  description = "Database Password"
  default     = "platform1234"
}

variable "db_postgres_version" {
  type = string
  description = "Postgres database version"
  default = "11.12" # TODO: Update this
}

variable "db_instance_class" {
  type = string
  description = "Size and Class for the RDS Postgres instance"
  default = "db.t3.micro" # TODO: update this
}
