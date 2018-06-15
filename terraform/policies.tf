data "template_file" "codebuild_policy" {
  template = "${file("policies/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "example-codebuild"
  assume_role_policy = "${file("policies/codebuild_role.json")}"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "example-codepipeline"

  assume_role_policy = "${file("policies/codepipeline_role.json")}"
}

data "template_file" "codepipeline_policy" {
  template = "${file("policies/codepipeline.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "example-codebuild"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "example-codepipeline"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}
