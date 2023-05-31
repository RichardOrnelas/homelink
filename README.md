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

#TODO: DNS and ACM cert
Setup the Rails App
Setup the CI/CD

## nice to hives
precommit
code change labels based on paths [infra, backend, database migration, SPA]
