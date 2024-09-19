output "migrate_extract_task_sg_id" {
  value = aws_security_group.migrate_extract_task.id
  description = "value of the migrate_extract_task security group id"
}

output "aws_efs_access_point_id" {
  value = aws_efs_access_point.db_dump.id
  description = "value of the postgres migrator efs access point id"
}

output "aws_efs_file_system_id" {
  value = aws_efs_file_system.db_dump.id
  description = "value of the postgres migrator efs file system id"
}
