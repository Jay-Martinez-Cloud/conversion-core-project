# terraform/envs/dev/iam_artifacts.tf
#
# Grants the private EC2 runner least-privilege access to write conversion artifacts
# into the artifacts bucket under runs/<env>/...
#
# Requires:
# - module.artifacts_s3.bucket_name output from artifacts_s3 module
# - module.runner.iam_role_name output from runner_ec2 module
# - var.env and var.project_name defined in envs/dev/variables.tf

data "aws_iam_policy_document" "runner_artifacts" {
  statement {
    sid     = "ListArtifactsPrefix"
    effect  = "Allow"
    actions = ["s3:ListBucket"]

    resources = [
      "arn:aws:s3:::${module.artifacts_s3.bucket_name}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["runs/${var.env}/*"]
    }
  }

  statement {
    sid    = "WriteArtifacts"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:PutObjectTagging"
    ]

    resources = [
      "arn:aws:s3:::${module.artifacts_s3.bucket_name}/runs/${var.env}/*"
    ]
  }
}

resource "aws_iam_policy" "runner_artifacts" {
  name        = "${var.project_name}-${var.env}-runner-artifacts"
  description = "Allow the ${var.env} conversion runner to write artifacts to S3 under runs/${var.env}/"
  policy      = data.aws_iam_policy_document.runner_artifacts.json
}

resource "aws_iam_role_policy_attachment" "runner_artifacts" {
  role       = module.runner.iam_role_name
  policy_arn = aws_iam_policy.runner_artifacts.arn
}
