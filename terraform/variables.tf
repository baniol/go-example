variable "pipeline_name" {
  default = "go-example-pipeline"
}

variable "source_bucket" {
  default = "go-example-pipeline"
}

variable "region" {
  default = "eu-central-1"
}

variable "repository_region" {
  default = "eu-central-1"
}

variable "repository_url" {
  default     = "500606609328.dkr.ecr.eu-central-1.amazonaws.com/go-example"
  description = "test"
}

variable "git_repository" {
  default = "go-example"
}

variable "git_organization" {
  default = "baniol"
}

variable "git_branch" {
  default = "terraform"
}

variable "codepipeline_polling" {
  default = "false"
}
