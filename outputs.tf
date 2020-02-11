output "master_security_group_id" {
  value       = join("", aws_security_group.master.*.id)
  description = "Master security group ID"
}

output "slave_security_group_id" {
  value       = join("", aws_security_group.slave.*.id)
  description = "Slave security group ID"
}

output "managed_master_security_group_id" {
  value       = join("", aws_security_group.managed_master.*.id)
  description = "Managed master security group ID"
}

output "managed_slave_security_group_id" {
  value       = join("", aws_security_group.managed_slave.*.id)
  description = "Managed slave security group ID"
}

output "managed_service_access_security_group_id" {
  value       = join("", aws_security_group.managed_service_access.*.id)
  description = "Managed service access security group ID"
}

output "ec2_instance_profile_arn" {
  value       = join("", aws_iam_instance_profile.ec2.*.arn)
  description = "EC2 IAM instance profile"
}
