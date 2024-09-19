output "migrate_extract_task_sg_id" {
  value = aws_security_group.migrate_extract_task.id
  description = "value of the migrate_extract_task security group id"
}
