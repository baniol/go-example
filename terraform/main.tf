provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "source" {
  bucket = "${var.source_bucket}"
  acl    = "private"

  #   tags = "${var.tags}"
}

data "template_file" "buildspec" {
  template = "${file("tpl/buildspec.tpl")}"

  vars {
    region            = "${var.region}"
    repository_region = "${var.repository_region}"
    container_name    = "go-example"

    # additional_build_args = "${join(" ", null_resource.build_args.*.triggers.result)}"
    # extra_docker_commands = "${var.extra_docker_commands}"
    # params_store          = "${length(var.build_params_store) == 0 ? "" : data.template_file.build_param_store.rendered}"
  }
}

/*
/* CodeBuild
*/
resource "aws_codebuild_project" "example_build" {
  name          = "go-example-project"
  build_timeout = "30"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/golang:1.10"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # environment_variable {
    #   name  = "NPM_TOKEN"
    #   value = "${data.aws_kms_secret.npm.token}"
    # }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${var.repository_url}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }

  #   tags = "${var.tags}"
}

/* CodePipeline */

resource "aws_codepipeline" "pipeline" {
  name     = "${var.pipeline_name}"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.bucket}"
    type     = "S3"
  }

  stage {
    name = "Clone_from_github"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner                = "${var.git_organization}"
        Repo                 = "${var.git_repository}"
        Branch               = "${var.git_branch}"
        PollForSourceChanges = "${var.codepipeline_polling}"
      }
    }
  }

  stage {
    name = "Build_and_push_docker_image"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${aws_codebuild_project.example_build.name}"
      }
    }
  }
}
