output "artifacts_bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}


output "sql_host_instance_id" {
  value = aws_instance.sql_host.id
}

output "sql_host_private_ip" {
  value = aws_instance.sql_host.private_ip
}
