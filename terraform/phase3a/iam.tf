#######################################
# IAM - EC2 Role for SSM + S3 Artifacts
#######################################

# EC2 assumes this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-ec2-role"
  })
}

# Allow SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Least-privilege S3 access to artifacts bucket
data "aws_iam_policy_document" "s3_artifacts_access" {
  statement {
    sid     = "ListArtifactsBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.artifacts.arn
    ]
  }

  statement {
    sid    = "RWArtifactsObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_artifacts_inline" {
  name   = "${local.name_prefix}-s3-artifacts-access"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.s3_artifacts_access.json
}

# Instance profile so EC2 can use the role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
