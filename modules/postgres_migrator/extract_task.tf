module "extract_task" {
  source = "../../resource-groups/ecs-fargate-task-definition"

  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
  container_definitions = {
    extract = {
      cpu                   = 2048
      environment_variables = []
      essential             = true
      healthcheck_command   = null
      image                 = var.cf_cli_docker_image
      memory                = 4096
      mounts = [
        {
          mount_point = local.fs_local_mount_path
          read_only   = false
          volume_name = "efs0"
        }
      ]
      override_command = [
        "sh", "-c",
        "apk update && apk add --no-cache postgresql-client && cf install-plugin -f conduit && cf login -a ${var.cf_api_endpoint} -u $CF_USERNAME -p $CF_PASSWORD -o ${var.cf_org} -s ${var.cf_space} && cf conduit ${var.cf_service_instance} -- pg_dump --file $DUMP_FILENAME --no-acl --no-owner"
      ]
      port = null
      secret_environment_variables = [
        { "name" : "CF_PASSWORD", "valueFrom" : local.cf_password_ssm_param_arn },
        { "name" : "CF_USERNAME", "valueFrom" : local.cf_username_ssm_param_arn }
      ]
    }
  }
  ecs_execution_role_arn = ""
  family_name            = "${var.process_name}-extract"
  task_cpu               = 0
  task_log_group_name    = module.task_log_group.log_group_name
  task_memory            = 0
}

resource "aws_security_group" "migrate_extract_task" {
  name        = "${var.process_name}-extract-task" # TODO rename
  description = "Security rules for the ${var.process_name}-extract task"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "migrate_extract_https_out_anywhere" {
  description = "Allows outbound https anywhere"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_extract_task.id
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "ssh_ish_out_anywhere" {
  description = "Allows outbound ssh_ish anywhere (bespoke requirement for cf conduit apparently)"
  # See https://github.com/alphagov/paas-cf-conduit/pull/65

  cidr_blocks = [
    "0.0.0.0/0"
  ]
  from_port         = 2222
  protocol          = "tcp"
  security_group_id = aws_security_group.migrate_extract_task.id
  to_port           = 2222
  type              = "egress"
}

resource "aws_iam_role_policy_attachment" "extract_task_role__write_logs" {
  role       = module.extract_task.task_role_name
  policy_arn = aws_iam_policy.write_logs.arn
}
