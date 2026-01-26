output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "azs" {
  value = module.vpc.azs
}

output "runner_instance_id" {
  value = module.runner.instance_id
}

output "runner_private_ip" {
  value = module.runner.private_ip
}

output "runner_security_group_id" {
  value = module.runner.security_group_id
}
