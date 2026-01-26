output "instance_id" {
  value = aws_instance.runner.id
}

output "security_group_id" {
  value = aws_security_group.runner.id
}

output "private_ip" {
  value = aws_instance.runner.private_ip
}

output "iam_role_name" {
  value = aws_iam_role.ssm_role.name
}

output "iam_role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}
