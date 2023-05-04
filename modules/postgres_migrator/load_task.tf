module "load_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id           = var.aws_account_id
  aws_region               = var.aws_region
  container_cpu            = 2048
  container_log_group_name = module.task_log_group.log_group_name
  container_memory         = 4096
  container_name           = "${var.process_name}-load"
  ecs_execution_role_arn   = var.ecs_execution_role_arn
  efs_mounts               = [
    {
      access_point_id = aws_efs_access_point.access.id
      file_system_id  = aws_efs_file_system.filesystem.id
      mount_point     = local.fs_local_mount_path
      read_only       = true
      volume_name     = "efs0"
    }
  ]
  family_name      = "${var.process_name}-load"
  image            = var.pg_docker_image
  override_command = [
    "sh", "-c",
    "psql postgres://${var.pg_db_username}:$PG_PASSWORD@${var.pg_db_endpoint}/${var.pg_db_name} < $DUMP_FILENAME"
  ]
  secret_environment_variables = [
    { "name" : "PG_PASSWORD", "valueFrom" : var.pg_db_password_ssm_param }
  ]
}

resource "aws_security_group" "migrate_load_task" {
  name        = "${var.process_name}-load-task"  # TODO rename
  description = "Security rules for the ${var.process_name}-load task"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "migrate_load_https_out_anywhere" {
  description = "Allows outbound https anywhere"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_load_task.id
  to_port           = 443
  type              = "egress"
}

resource "aws_iam_role_policy_attachment" "load_task_role__write_logs" {
  role       = module.load_task.task_role_name
  policy_arn = aws_iam_policy.write_logs.arn
}
