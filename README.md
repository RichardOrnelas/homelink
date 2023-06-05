# Homelink
<!-- TODO: Project Description -->
[![PR Test Environment](https://github.com/RichardOrnelas/homelink/actions/workflows/pull_request.yml/badge.svg?event=pull_request)](https://github.com/RichardOrnelas/homelink/actions/workflows/pull_request.yml)
[![Test Environment Cleanup](https://github.com/RichardOrnelas/homelink/actions/workflows/pull_request_closed.yml/badge.svg)](https://github.com/RichardOrnelas/homelink/actions/workflows/pull_request_closed.yml)
[![Deploy Sandbox Environment](https://github.com/RichardOrnelas/homelink/actions/workflows/main_merge.yml/badge.svg)](https://github.com/RichardOrnelas/homelink/actions/workflows/main_merge.yml)
[![Deploy Staging Environment](https://github.com/RichardOrnelas/homelink/actions/workflows/prerelease.yml/badge.svg)](https://github.com/RichardOrnelas/homelink/actions/workflows/prerelease.yml)

## Architecture
Homelink is a Ruby on Rails application that houses a simple user directory service. It allows users to create a profile, login to that profile, and update their profile, including a profile picture. It stores this data in a Postgres database, and leverages an Active Job processor to handle async operations using a queueing strategy.

### AWS Resources
I made an assumption that the service would live inside a current VPC, so it begins with the assumption that there is a VPC provided with some sort of tagging strategy. I built a new VPC for this project, but that is not a requirement. Simply need to update tagging in the infrastructure `.infrastructure/main.tf` to update the VPC.

Under the hood in AWS, Homelink leverages the following:
* AWS Elastic Container Service for Web and Worker container hosting.
* AWS Application Load Balancer for managing web connections
* AWS Relational Database Service for the PostGres db.
* AWS Simple Queue Service for high and low queues, and corresponding dead letter queues.
* AWS S3 bucket for storing attachments 

### Dependencies and Requirements
* terraform 1.4.6
* ruby 3.2.2
* postgres 15.2 
* nodejs 20.2.0
* AWS credentials for the sandbox environment
* See [setup](###-Setup) for local development setup



## CI/CD
flow, secrets, processes, actions, environments
### Operating Environments



## Local Development

### Setup
To setup your local developer environment, clone the repository to your local machine, and install these dependencies.

NOTE: To build and run the Docker image locally, you will need Docker installed.

- _Optional_ Install Homebrew
  ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc
    source ~/.zshrc # If you see weird behavior, restart your terminal
    brew doctor
  ```
- Install `asdf`
  ```
    brew install coreutils curl git gpg gawk zsh yarn asdf
    echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
    echo 'legacy_version_file = yes' >> ~/.asdfrc
  ```
- Install Terraform
  ```
  asdf plugin add terraform
  asdf install terraform 1.4.6
  asdf global terraform 1.4.6
  ```
- Install Ruby
  ```
  asdf plugin add ruby
  asdf install ruby 3.2.2
  asdf global ruby 3.2.2
  ```
- Install Node
  ```
  asdf plugin add nodejs
  asdf install nodejs latest
  asdf global nodejs latest
  ```
- Install PostGres
  ```
  asdf plugin add postgres
  asdf install postgres 15.2
  asdf global postgres 15.2
  $HOME/.asdf/installs/postgres/15.2/bin/pg_ctl -D $HOME/.asdf/installs/postgres/15.2/data -l logfile start
  ```
- Install Rails
  `gem install bundler rails`


### Working with Rails

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions


### Working with Terraform



###


CI Variable List
AWS_REGION
AWS_ACCOUNT_ID
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

TF variables
variable "project"
variable "region"
variable "ip_whitelist"
variable "db_password"
variable "db_postgres_version"
variable "db_parameter_group"
variable "db_instance_class"

Ruby Variables 
RAILS_LOG_TO_STDOUT=true
LOG_LEVEL=info
PORT=8080
DATABASE_URL="postgres://localhost"
RAILS_ENV=development
APP_BUCKET_NAME="foo"
DEFAULT_QUEUE="foo"

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

## System Setup
- _Optional_ Install Homebrew
  ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc
    source ~/.zshrc # If you see weird behavior, restart your terminal
    brew doctor
  ```
- Install `asdf`
  ```
    brew install coreutils curl git gpg gawk zsh yarn asdf
    echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
    echo 'legacy_version_file = yes' >> ~/.asdfrc
  ```
- Install Ruby
  ```
  asdf plugin add ruby
  asdf install ruby 3.2.2
  asdf global ruby 3.2.2
  ```
- Install PostGres
  ```
  asdf plugin add postgres
  asdf install postgres 15.2
  asdf global postgres 15.2
  $HOME/.asdf/installs/postgres/15.2/bin/pg_ctl -D $HOME/.asdf/installs/postgres/15.2/data -l logfile start
  ```
- Install Rails
  `gem install bundler rails`
- Bundle
  `bundle install`
- Setup Database
  `RAILS_ENV=development rails db:create db:migrate`

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# homelink
Chainlink Take Home Project


# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Infrastructure setup
1. create readme.
2. .gitignore
3. .toolversions and set versions
  ```
  touch .toolversions
  asdf local terraform 1.4.6
  ```
4. Pre-commit install and Terraform config `pre-commit install`
  ```
  touch.pre-commit-config.yaml
  pre-commit install
  ```
5. create `infrastructure` directory

Setup the CI/CD

## nice to hives
precommit
code change labels based on paths [infra, backend, database migration, SPA]

# 

# Terraform Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_target_group.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_cloudwatch_log_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecr_repository.homelink](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_iam_role.platform_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.platform_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.alb_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.alb_public_443_platform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.alb_public_80_platform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_sg_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_sg_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.rds_postgres_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sqs_queue.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.queue_dead](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_ssm_parameter.APP_BUCKET](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.DATABASE_URL](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_acm_certificate.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_iam_policy_document.grant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.platform_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Size and Class for the RDS Postgres instance | `string` | `"db.t3.micro"` | no |
| <a name="input_db_parameter_group"></a> [db\_parameter\_group](#input\_db\_parameter\_group) | Postgres database parameter group name | `string` | `"default.postgres15"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Database Password | `string` | `"platform1234"` | no |
| <a name="input_db_postgres_version"></a> [db\_postgres\_version](#input\_db\_postgres\_version) | Postgres database version | `string` | `"15.3"` | no |
| <a name="input_ip_whitelist"></a> [ip\_whitelist](#input\_ip\_whitelist) | IP Whitelist for non-production | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | Name of the project | `string` | `"chainlink"` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | ## SQS ### | `list(string)` | <pre>[<br>  "main",<br>  "high"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to deploy resources in | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_bucket"></a> [app\_bucket](#output\_app\_bucket) | n/a |
| <a name="output_db_arn"></a> [db\_arn](#output\_db\_arn) | n/a |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | n/a |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | n/a |
| <a name="output_sg_alb_public"></a> [sg\_alb\_public](#output\_sg\_alb\_public) | n/a |
| <a name="output_sg_ecs"></a> [sg\_ecs](#output\_sg\_ecs) | n/a |
| <a name="output_sg_rds"></a> [sg\_rds](#output\_sg\_rds) | n/a |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | n/a |
| <a name="output_www_fqdn"></a> [www\_fqdn](#output\_www\_fqdn) | n/a |
<!-- END_TF_DOCS -->
